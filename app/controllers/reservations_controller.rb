class ReservationsController < ApplicationController
  load_and_authorize_resource
  # Can't autoload new action because params don't match up to column names in DB
  skip_load_resource :only => [:new]
  respond_to :html, :js
  respond_to :json, :csv, :except => [:new, :edit]

  # GET /reservations
  def index
    @user = current_user
    @reservation = @user.reservations.new
    @reservations = @user.reservations.active.no_blocks.current

    respond_with(@reservations)
  end

  # GET /reservations/new
  def new
    @user = current_user
    @reservation = @user.reservations.new
    # Need to reset these to properly formatted dates in UTC
    # b/c using strong parameters somehow formats them
    @reservation.start_dt = start_dt
    @reservation.end_dt = end_dt

    # Manually authorize these actions so that we can load a custom message
    [:create_today, :create_for_same_day, :create_for_length].each do |action|
      authorize! action, @reservation
    end
    @rooms = RoomsDecorator.new(rooms_search)
    # Existing reservations for this collection of rooms in this range
    @existing_reservations = @rooms.find_reservations_by_range(start_dt - 1.hour, end_dt + 1.hour)

    respond_with(@reservation)
  end

  # POST /reservations
  def create
    @user = current_user
    @reservation = @user.reservations.new(create_params)
    # Need to reset these to properly formatted dates in UTC
    # b/c using strong parameters somehow formats them
    @reservation.start_dt = start_dt
    @reservation.end_dt = end_dt
    @room = @reservation.room

    # Manually authorize these actions so that we can load a custom message
    [:create_today, :create_for_same_day, :create_for_length].each do |action|
      authorize! action, @reservation
    end

    @rooms = RoomsDecorator.new(rooms_search)
    # Existing reservations for this collection of rooms in this range
    @existing_reservations = @rooms.find_reservations_by_range(start_dt - 1.hour, end_dt + 1.hour)

    respond_with(@reservation) do |format|
      if @reservation.save
        # Send email
        ReservationMailer.confirmation_email(@reservation).deliver_now
        flash[:success] = t('reservations.create.success').html_safe
        format.html { render :index }
      else
        format.html { render :new, params: params }
        format.js { render :new, params: params }
      end
    end
  end

  # GET /reservations/1/edit
  def edit
    @reservation = Reservation.find(params[:id])
    @user = current_user

    respond_with(@reservation)
  end

  # PUT /reservations/1
  def update
    @reservation = Reservation.find(params[:id])
    @user = @reservation.user

    flash[:success] = t('reservations.update.success') if @reservation.update_attributes(update_params)

    respond_with(@reservation, :location => root_url)
  end

  # PUT /reservations/1
  def delete
    @reservation = Reservation.find(params[:reservation_id])
    @reservation.deleted = true
    @reservation.deleted_by = { :by_user => current_user.id }
    @user = @reservation.user

    if @reservation.save
      flash[:success] = t('reservations.delete.success')
      # Send email
      ReservationMailer.cancellation_email(@reservation).deliver_now
    else
      flash[:error] = t('reservations.delete.error')
    end

    respond_with(@reservation) do |format|
      format.html { redirect_to (params[:return_url] || user_path(@user)) }
    end
  end

  # RESEND confirmation email
  def resend_email
    @user = current_user
    @reservation = @user.reservations.find(params[:id])

    # Send email
    if ReservationMailer.confirmation_email(@reservation).deliver_now
      flash[:success] = t('reservations.resend_email.success')
    end

    respond_with(@reservation, :location => root_url)
  end

  # Implement sort column function for this model
  def sort_column
    super "Room", "sort_order"
  end
  helper_method :sort_column

  # Get the Start DateTime from the start_dt param or from the which_date param,
  # depending on which is present,
  # which_date present on #new and start_dt present on #create
  def start_dt
    @start_dt ||=
      (params[:reservation][:start_dt].blank?) ?
        DateTime.new(which_date.year, which_date.mon, which_date.mday, hour, params[:reservation][:minute].to_i) :
        DateTime.parse(params[:reservation][:start_dt])
  rescue StandardError => e
    flash[:error] = t('reservation.date_formatted_correctly')
    @start_dt ||= default_date
  end
  helper_method :start_dt

  # Get the End DateTime, by adding the how_long param to Start DateTime
  def end_dt
    @end_dt ||=
     (params[:reservation][:end_dt].nil?) ?
      start_dt + params[:reservation][:how_long].to_i.minutes :
        DateTime.parse(params[:reservation][:end_dt])
  rescue StandardError => e
    flash[:error] = t('reservation.date_formatted_correctly')
    @endt_dt ||= default_date
  end
  helper_method :end_dt

private

  # Parse single date field into date object
  def which_date
    @which_date ||= Date.parse(params[:reservation][:which_date])
  rescue StandardError => e
    flash[:error] = t('reservation.date_formatted_correctly')
    @which_date = Date.today
  end

  # Convert 12 to 24 hours
  def hour
    @hour ||= get_hour_in_24(params[:reservation])
  end

  # Default date to NOW
  def default_date
    @default_date ||= DateTime.new(Time.now.year, Time.now.mon, Time.now.mday, Time.now.hour, 0)
  end

  def rooms_search
    # Default elasticsearch options
    options = default_elasticsearch_options
    # Get room groups this user can admin
    room_group_filter = RoomGroup.all.map(&:code).reject { |r| cannot? r.to_sym, RoomGroup }
    # Boolean if this is default sort or a re-sort
    resort = (sort_column.to_sym != options[:sort])
    # Get Rooms from elasticsearch through DSL
    query = Elasticsearch::DSL::Search.search do
      query do
        terms room_group: room_group_filter, execution: "or"
      end
      # Default sort by room group and then default
      sort do
        by :room_group, 'asc'
        by options[:sort], options[:direction]
      end unless resort
      sort { by options[:sort], options[:direction] } if resort
      page = options[:page].to_i
      search_size = options[:per].to_i
      from (page -1) * search_size
      size search_size
    end
    rooms_search = Room.search(query)
    return rooms_search
  end

  def update_params
    params.require(:reservation).permit(:title)
  end

  def create_params
    params.require(:reservation).permit(:room_id, :cc, :title, :user_id, :start_dt, :end_dt)
  end

end
