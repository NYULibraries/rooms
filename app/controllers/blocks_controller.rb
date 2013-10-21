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
    @block.title = (params[:reservation][:title].blank?) ? t('blocks.default_title') : params[:reservation][:title]
    
    respond_with(@block) do |format|
      if @block.save
        format.html { redirect_to blocks_url, notice: t('blocks.create.success') }
      else
        format.html { render :new, params: params }
      end
    end
  end
  
  def destroy_multiple
    @block = Reservation.new(params[:reservation])
    @block.user_id = current_user.id
    @block.is_block = true
    @block.title = (params[:reservation][:title].blank?) ? t('blocks.default_title') : params[:reservation][:title]
    
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
      # Send an email to the administrator specified if the checkbox was selected
      ReservationMailer.block_cancellation_admin_email(@block, formatted_reservations, params[:cc_admin_email], params[:cancel]).deliver if params[:cc_admin]
    end
    
    if @block.save
      redirect_to blocks_url, notice: t('blocks.destroy_multiple.success')
    else
      # If the block can't save, you will render :new with a list of existing reservations and options
      flash[:error] = t('blocks.destroy_multiple.error')
      render :new, params: params
    end
  end
  
  # DELETE /blocks/1
  def destroy
    @block = Reservation.find(params[:id])
    flash[:notice] = t('blocks.destroy.success') if @block.destroy

    respond_with(@block, :location => blocks_url)
  end
  
  def existing_reservations
    @existing_reservations = Reservation.find(params[:reservations_to_delete])
  end
  
end