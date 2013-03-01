class BlocksController < ApplicationController
  before_filter :authenticate_admin
  respond_to :html, :js
  
  # GET /blocks
  def index
    @blocks = Reservation.blocks.joins(:room).sorted(params[:sort], "start_dt ASC").page(params[:page]).per(30)
    @rooms = Room.all
    respond_with(@blocks)
  end
  
  # GET /blocks/new
  def new
    @block = Reservation.new
  end
  
  # Generates new block request for approval before creating
  def generate
    @block = Reservation.new(params[:block]) 
    @room = Room.find(params[:block][:room_id])
    
    @start_dt = params[:block][:start_dt] unless params[:block][:start_dt].blank?
    @end_dt = params[:block][:end_dt] unless params[:block][:end_dt].blank?
     
    # Find all reservations that fall between this selected date range      
    @existing_reservations = Reservation.active_non_blocks.where("room_id = ? AND start_dt >= ? AND ((start_dt BETWEEN ? AND ?) OR (end_dt BETWEEN ? AND ?) OR (start_dt <= ? AND end_dt >= ?))", params[:block][:room_id], Time.now, @start_dt, @end_dt, @start_dt, @end_dt, @start_dt, @end_dt)

    # Set the fields to the proper datetime objects   
    @block.start_dt = @start_dt
    @block.end_dt = @end_dt
    @block.title = "Scheduled closure" if params[:block][:title].blank?
    
    respond_with(@block)
  end
  
  # POST /blocks
  def create
    @block = Reservation.new(params[:block])
    @block.user_id = current_user.id
    @block.is_block = true
    @room = Room.find(params[:block][:room_id])

    @start_dt = params[:block][:start_dt] unless params[:block][:start_dt].blank?
    @end_dt = params[:block][:end_dt] unless params[:block][:end_dt].blank?
    
    # If there are existing reservations and a cancellation request has been submitted...
    unless params[:cancel].blank?
      # Delete all found reservations
      formatted_reservations = ""
      @existing_reservations = Reservation.find(params[:reservations_to_delete])
      @existing_reservations.each do |res|
        # Mark reservation as deleted
        if res.update_attributes(:deleted => true, :deleted_by => { :by_block => true })
          # Send an email if choice to alert users was made
          ReservationMailer.block_cancellation_email(res, params[:cc_group], params[:cancellation_email]).deliver if params[:cancel].eql? "delete_with_alert"
          formatted_reservations += "User: #{res.user.username}; Room: #{res.room.title}; Reservation: #{res.start_dt.strftime('%a. %b %d, %Y %I:%M %p')} -- #{res.end_dt.strftime('%a. %b %d, %Y %I:%M %p')}\n"
        else
          flash[:error] = "Could not delete reservation with id: #{res.id}. Please report this to the system administrator: gswg@library.nyu.edu."
          render :new and return false
        end
      end
      # Send an email to the administrator specified if the checkbox was selected
      ReservationMailer.block_cancellation_admin_email(@block, formatted_reservations, params[:cc_admin_email], params[:cancel]).deliver if params[:cc_admin]
    end
   
    respond_with(@block) do |format|
      if @block.save
        flash[:success] = 'Block successfully created.'
        format.html { redirect_to blocks_url }
      else
        flash[:error] = "Could not save block. If this problem persists please report to administrator."
        format.html { render :new }
      end
    end
  end
  
  # DELETE /blocks/1
  def destroy
    @block = Reservation.find(params[:id])
    @block.destroy

    flash[:notice] = "Block was successfully deleted."    
    respond_with(@block) do |format|
      format.html { redirect_to blocks_url }
    end
  end
  
end