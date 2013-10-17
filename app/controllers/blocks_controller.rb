class BlocksController < ApplicationController
  authorize_resource :class => false
  respond_to :html, :js
  
  # GET /blocks
  def index
    @blocks = Reservation.blocks.joins(:room).sorted(params[:sort], "start_dt asc").page(params[:page]).per(30)
    @rooms = Room.all
    respond_with(@blocks)
  end
  
  # GET /blocks/new
  def new
    @block = Reservation.new
    respond_with(@block)
  end
  
  # POST /blocks
  def create
    @block = Reservation.new(params[:reservation])
    @block.user_id = current_user.id
    @block.is_block = true
    @block.title = (params[:reservation][:title].blank?) ? "Scheduled closure" : params[:reservation][:title]
    
    respond_with(@block) do |format|
      if @block.save
        flash[:notice] = "Block successfully created."
        format.html { redirect_to blocks_url, notice: "Block successfully created." }
      else
        # If the block can't save, you will render :new with a list of existing reservations and options
        @existing_reservations = Reservation.existing_reservations(params[:reservation][:room_id], params[:reservation][:start_dt], params[:reservation][:end_dt], true, 1000)
        format.html { render :new, params: params }
      end
    end
  end
  
  def destroy_multiple
    @block = Reservation.new(params[:reservation])
    @block.user_id = current_user.id
    @block.is_block = true
    @block.title = (params[:reservation][:title].blank?) ? "Scheduled closure" : params[:reservation][:title]
    
    # If this has been submitted with a cancel request, delete conflicting reservations
    unless params[:cancel].blank? || params[:reservations_to_delete].blank?
      formatted_reservations = ""
      reservations_to_delete = Reservation.find(params[:reservations_to_delete])
      reservations_to_delete.each do |res|
        # Mark reservation as deleted
        if res.update_attributes(:deleted => true, :deleted_by => { :by_block => true })
          # Send an email if choice to alert users was made
          ReservationMailer.block_cancellation_email(res, params[:cc_group], params[:cancellation_email]).deliver if params[:cancel].eql? "delete_with_alert"
          # Format each deleted reservation to send email to admin
          formatted_reservations += "User: #{res.user.username}; Room: #{res.room.title}; Reservation: #{res.start_dt.strftime('%a. %b %d, %Y %I:%M %p')} -- #{res.end_dt.strftime('%a. %b %d, %Y %I:%M %p')}\n"
        end
      end
      Tire.index("#{Rails.env}_reservations").refresh
      # Send an email to the administrator specified if the checkbox was selected
      ReservationMailer.block_cancellation_admin_email(@block, formatted_reservations, params[:cc_admin_email], params[:cancel]).deliver if params[:cc_admin]

      #reservations_not_deleted = Reservation.find(params[:reservations_to_delete]).delete_if {|res| res.deleted? }
    end
    
    if @block.save
      redirect_to blocks_url, notice: "Block successfully created." 
    else
      # If the block can't save, you will render :new with a list of existing reservations and options
      flash[:error] = "Could not delete existing reservations. Please contact web administrator web.services@library.nyu.edu."
      render :new, params: params
    end
  end
  
  # DELETE /blocks/1
  def destroy
    @block = Reservation.find(params[:id])
    flash[:notice] = "Block was successfully deleted." if @block.destroy

    respond_with(@block, :location => blocks_url)
  end
  
  def existing_reservations
    @existing_reservations = Reservation.find(params[:reservations_to_delete])
  end
  
end