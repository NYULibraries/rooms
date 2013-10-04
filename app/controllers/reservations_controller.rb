class ReservationsController < ApplicationController
  before_filter :authorize_patron
  respond_to :html, :js
  respond_to :xml, :json, :csv, :except => [:new, :edit]

  # GET /reservations
  def index
    @user = current_user
    @reservation = @user.reservations.new
    @reservations = @user.reservations.active_non_blocks.current

    respond_with(@reservations)
  end

  # GET /reservations/1
  def show
    @reservation = Reservation.find(params[:id])
    
    respond_with(@reservation)
  end

  # GET /reservations/new
  def new
    @user = current_user
    begin
      @reservation = @user.reservations.new(:start_dt => start_dt, :end_dt => end_dt)
      options = { :direction => (params[:direction] || 'asc'), :sort => (params[:sort] || sort_column.to_sym), :page => (params[:page] || 1), :per => (params[:per] || 20) }  
      @rooms = Room.tire.search do
        sort { by options[:sort], options[:direction] }
        page = options[:page].to_i
        search_size = options[:per].to_i
        from (page -1) * search_size
        size search_size
      end
    rescue ArgumentError => e
      @reservation = @user.reservations.new
      flash[:error] = "Please select a valid future date in the format YYYY-MM-DD." if e.message == "invalid date"
    end
    
    if @reservation.rr_made_today?
      flash[:error] = "Sorry, you are only allowed <strong>to create one reservation per day.</strong>".html_safe
    elsif @reservation.rr_for_same_day?
      flash[:error] = "Sorry, you are only allowed <strong>to have one reservation per day.</strong>".html_safe
    end

    respond_with(@reservation) do |format|
      if flash[:error].blank?
        format.html { render :new }
      else
        format.html { render :index }
      end
    end
  end

  # GET /reservations
  def create   
    @user = current_user
    @reservation = @user.reservations.new(params[:reservation])
    #@reservation.created_at_day = Time.zone.now.strftime("%Y-%m-%d")
    #@reservation.created_at_timezone = Time.zone.name
    @room = @reservation.room
    
    options = { :direction => (params[:direction] || 'asc'), :sort => (params[:sort] || sort_column.to_sym), :page => (params[:page] || 1), :per => (params[:per] || 20) }  
    @rooms = Room.tire.search do
      sort { by options[:sort], options[:direction] }
      page = options[:page].to_i
      search_size = options[:per].to_i
      from (page -1) * search_size
      size search_size
    end

    respond_with(@reservation) do |format|
      if @reservation.save
        # Send email
        ReservationMailer.confirmation_email(@reservation).deliver
        flash[:success] = 'Reservation was successful. You will be sent an e-mail confirming your reservation.'
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
    respond_with(@reservation)
  end

  # PUT /reservations/1
  def update
    @reservation = Reservation.find(params[:id])
    @user = current_user

    if @reservation.update_attributes(params[:reservation])
      flash[:success] = 'Reservation was successfully updated.'
    end

    respond_with(@reservation, :location => root_url)
  end

  # PUT /reservations/1
  def delete
    @user = current_user    
    @reservation = @user.reservations.find(params[:reservation_id])
    @reservation.deleted = true
    @reservation.deleted_by = { :by_user => current_user.id }
    #@reservation.deleted_at_timezone = Time.zone.name

    if @reservation.save
      flash[:success] = "Reservation was successfully deleted."
      # Send email
      ReservationMailer.cancellation_email(@reservation).deliver
    else 
      flash[:error] = "Could not delete this reservation. Please report this to the system administrator: gswg@library.nyu.edu."
    end
    
    respond_with(@reservation) do |format|
      format.js
      if @user.is? :admin and in_admin_view?
        format.html { redirect_to user_path(@user) } 
      else
        format.html { redirect_to root_url }
      end
    end
  end
  
  # RESEND confirmation email
  def resend_email
    @user = current_user    
    @reservation = @user.reservations.find(params[:id])
    
    # Send email
    if ReservationMailer.confirmation_email(@reservation).deliver
       flash[:success] = "E-mail successfully resent: A confirmation for this reservation has been sent to your email address."
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
        DateTime.new(which_date.year, which_date.mon, which_date.mday, hour.to_i, params[:reservation][:minute].to_i) :
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
  
  def which_date
    @which_date ||= Date.parse(params[:reservation][:which_date])
  end
  
  def hour
    # convert 12 hour to 24 hour for storing
    if params[:reservation][:ampm] == "pm" && params[:reservation][:hour] != "12"
      hour = params[:reservation][:hour].to_i + 12
    elsif params[:reservation][:ampm] == "am" && params[:reservation][:hour] == "12" 
      hour = 0
    else 
      hour = params[:reservation][:hour].to_i 
    end
    return hour
  end
  
end


