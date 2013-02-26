class ReservationsController < ApplicationController
  before_filter :authorize_patron
  respond_to :html, :js
  respond_to :xml, :json, :except => [:new, :edit]

  # GET /reservations
  def index
    @reservation = Reservation.new
    @user = current_user
    @reservations = @user.reservations
    
    respond_with(@reservations)
  end

  # GET /reservations/1
  def show
    @reservation = Reservation.find(params[:id])
    
    respond_with(@reservation)
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
    @rooms = Room.sorted(params[:sort], "sort_order ASC").page(params[:page]).per(10)
    @user = current_user
    @start_dt = DateTime.parse(params[:reservation][:start_dt]) unless params[:reservation][:start_dt].nil?
    @end_dt = DateTime.parse(params[:reservation][:end_dt]) unless params[:reservation][:end_dt].nil?
  
    if (@start_dt.nil? || @end_dt.nil?) and params[:reservation][:which_date].match(/\d\d\d\d-\d\d-\d\d/) 
      # construct DateTime object from calendar params submitted
      date = Date.parse(params[:reservation][:which_date])
      # convert 12 hour to 24 hour for storing
      if params[:reservation][:ampm] == "pm" && params[:reservation][:hour] != "12"
        hour = params[:reservation][:hour].to_i + 12
      elsif params[:reservation][:ampm] == "am" && params[:reservation][:hour] == "12" 
        hour = 0
      else 
        hour = params[:reservation][:hour].to_i 
      end
      
      # set start and end times as DateTime objects to insert into database if valid
      @start_dt = DateTime.new(date.year, date.mon, date.mday, hour.to_i, params[:reservation][:minute].to_i)
      @end_dt = @start_dt + params[:reservation][:how_long].to_i.minutes unless @start_dt.blank?
    end
    
    if @start_dt.blank? || @start_dt < DateTime.new(DateTime.now.year, DateTime.now.month, DateTime.now.day, 0,0)
      flash[:error] = "Please select a valid future date in the format YYYY-MM-DD."
    elsif rr_made_today?
      flash[:error] = "Sorry, you are only allowed <strong>to create one reservation per day.</strong>"
    elsif rr_for_same_day?
      flash[:error] = "Sorry, you are only allowed <strong>to have one reservation per day.</strong>"
    end

    respond_with(@reservation) do |format|
      format.html { render :index } unless flash[:error].blank?
      format.js { render :layout => false }
    end
    
  end

  # GET /reservations
  def create
    @reservation = Reservation.new(params[:reservation])
    @user = @reservation.user
    @room = @reservation.room
    @rooms = Room.sorted(params[:sort], "sort_order ASC").page(params[:page]).per(10)
   
    @start_dt = DateTime.parse(params[:reservation][:start_dt]) unless params[:reservation][:start_dt].nil?
    @end_dt = DateTime.parse(params[:reservation][:end_dt]) unless params[:reservation][:end_dt].nil?
    
    respond_with(@reservation) do |format|
      if @reservation.save
        # Send email
        ReservationMailer.confirmation_email(@reservation).deliver
        flash[:success] = 'Reservation was successful. You will be sent an e-mail confirming your reservation.'
        format.html { render :index }
      else
        format.html { render :new, params: params }
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

    respond_with(@reservation, :location => root_url) do |format|
      format.js { render :layout => false }
    end
  end

  # DELETE /reservations/1
  def destroy
    # TODO: This is not RESTful and should probably be a PUT
    @reservation = Reservation.find(params[:id])
    
    if @reservation.update_attributes(:deleted => true, :deleted_by => { :by_user => current_user.id })
      flash[:notice] = "Reservation was successfully deleted."
      # Send email
      ReservationMailer.cancellation_email(@reservation).deliver
    else 
      flash[:error] = "Could not delete this reservation. Please report this to the system administrator: gswg@library.nyu.edu."
    end
    
    respond_with(@reservation, :location => params[:return_to]) do |format|
      format.js { render :layout => false }
      if is_admin? and is_in_admin_view?
        format.html { redirect_to user_path(@reservation.user) } 
      else
        format.html { redirect_to root_url }
      end
    end
  end
  
  # RESEND confirmation email
  def resend_email
    @reservation = Reservation.find(params[:id])
    @user = @reservation.user
    # Send email
    ReservationMailer.confirmation_email(@reservation).deliver
    
    respond_with(@reservation, :location => root_url) do |format|
      format.js { render :layout => false }
    end
  end
  
private 
  
  #Perform a check to find if the user has already created a reservation today
  def rr_made_today?
    # find today's date as comparable object
    d_now = DateTime.now.strftime('%Y%m%d').to_i
    # find if this user has already made a reservation today...
    @rr_made_today = Reservation.active_non_blocks.where("user_id = ? AND DATE_FORMAT(created_at,'%Y%m%d') = ?", @user.id, d_now)
    return false if @rr_made_today.blank? || @user.user_attributes[:room_reserve_admin]
    return true
  end
  
  #Perform a check to find if the user already has a reservation for this day
  def rr_for_same_day?
    # find date of reservation as comparable object
    reservation_day = @start_dt.strftime('%Y%m%d').to_i
    # or if they made a reservation for the selected day already
    @rr_for_same_day = Reservation.active_non_blocks.where("user_id = ? AND DATE_FORMAT(start_dt,'%Y%m%d') = ?", @user.id, reservation_day)
    return false if @rr_for_same_day.blank? || @user.user_attributes[:room_reserve_admin]
    return true
  end


end


