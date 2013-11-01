class ReservationsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => [:new, :edit, :create]
  skip_authorize_resource :only => :create
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
    @reservation = @user.reservations.new(:start_dt => start_dt, :end_dt => end_dt)

    # Manually authorize
    [:made_today, :for_same_day, :create_length].each do |action|
      authorize! action, @reservation
    end
    
    # Options for ElasticSearch
    options = { :direction => (params[:direction] || 'asc'), :sort => (params[:sort] || sort_column.to_sym), :page => (params[:page] || 1), :per => (params[:per] || 20) }  
    room_group_filter = RoomGroup.all.map(&:code).reject { |r| cannot? r.to_sym, RoomGroup }
    resort = (sort_column.to_sym != options[:sort])
    # Get Rooms from ElasticSearch through tire DSL
    rooms = Room.tire.search do
      filter :terms, :room_group => room_group_filter, :execution => "or"
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
    @rooms = RoomsDecorator.new(rooms)

    respond_with(@reservation)
  end

  # POST /reservations
  def create
    @user = current_user
    @reservation = @user.reservations.new(params[:reservation])
    @room = @reservation.room

    # Manually authorize
    [:made_today, :for_same_day, :create_length].each do |action|
      authorize! action, @reservation
    end
    
    options = { :direction => (params[:direction] || 'asc'), :sort => (params[:sort] || sort_column.to_sym), :page => (params[:page] || 1), :per => (params[:per] || 20) }  
    room_group_filter = RoomGroup.all.map(&:code).reject { |r| cannot? r.to_sym, RoomGroup }
    resort = (sort_column.to_sym != options[:sort])
    # Get Rooms from ElasticSearch through tire DSL
    @rooms = Room.tire.search do
      filter :terms, :room_group => room_group_filter, :execution => "or"
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

    respond_with(@reservation) do |format|
      if @reservation.save
        # Send email
        ReservationMailer.confirmation_email(@reservation).deliver
        flash[:success] = t('reservations.create.success')
        format.html { render :index }
        format.js 
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
    
    #Explicitly authorize reservation creation here
    authorize! :update, @reservation
    
    respond_with(@reservation)
  end

  # PUT /reservations/1
  def update
    @reservation = Reservation.find(params[:id])
    @user = @reservation.user

    flash[:success] = t('reservations.update.success') if @reservation.update_attributes(params[:reservation])

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
      ReservationMailer.cancellation_email(@reservation).deliver
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
    if ReservationMailer.confirmation_email(@reservation).deliver
       flash[:success] = t('reservations.resend_email.success')
     end
    
    respond_with(@reservation, :location => root_url)
  end
  
  # Implement sort column function for this model
  def sort_column
    super "Room", "sort_order"
  end
  helper_method :sort_column
   
  def start_dt
    @start_dt ||= 
      (params[:reservation][:start_dt].blank?) ? 
        DateTime.new(which_date.year, which_date.mon, which_date.mday, hour, params[:reservation][:minute].to_i) :
          DateTime.parse(params[:reservation][:start_dt]) 
  end
  helper_method :start_dt
  
  def end_dt
    @end_dt ||=
     (params[:reservation][:end_dt].nil?) ? 
      start_dt + params[:reservation][:how_long].to_i.minutes :
        DateTime.parse(params[:reservation][:end_dt])
  end
  helper_method :end_dt
  
private 

  # Parse single date field into date object
  def which_date
    @which_date ||= Date.parse(params[:reservation][:which_date])
  end
  
  # Convert 12 to 24 hours
  def hour
    @hour ||= (params[:reservation][:ampm] == "pm" && params[:reservation][:hour] != "12") ? params[:reservation][:hour].to_i + 12 :
                (params[:reservation][:ampm] == "am" && params[:reservation][:hour] == "12") ? hour = 0 :
                  params[:reservation][:hour].to_i 
  end
  
end


