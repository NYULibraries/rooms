class BlocksController < ApplicationController
  # Authorize as symbol without class since this is only for RESTful actions
  authorize_resource :block, :class => false
  respond_to :html, :js
  before_filter :set_block, :only => [:create, :destroy_existing_reservations]

  # GET /blocks
  def index
    @blocks = Reservation.blocks.joins(:room).accessible_by(current_ability).sorted(params[:sort], "start_dt asc").page(params[:page]).per(30)
    @rooms = Room.all
    respond_with(@blocks)
  end

  # GET /blocks/new
  def new
    @block = Reservation.new(:is_block => true)
    respond_with(@block)
  end

  # POST /blocks
  def create
    respond_with(@block) do |format|
      if @block.save
        format.html { redirect_to blocks_url, flash: {success: t('blocks.create.success')} }
      else
        format.html { render :new }
      end
    end
  end

  # DELETE /blocks/1
  def destroy
    @block = Reservation.find(params[:id])
    flash[:notice] = t('blocks.destroy.success') if @block.destroy

    respond_with(@block, :location => blocks_url)
  end

  # POST /blocks/destroy_existing_reservations
  def destroy_existing_reservations
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

    # Jumping through hoops here to avoid ElasticSearch caching class method existing_reservations when @block.save is called
    reservations_still_exist = Reservation.where(:id => params[:reservations_to_delete], :deleted => false)
    if reservations_still_exist.empty?
      redirect_to blocks_url, notice: t('blocks.destroy_existing_reservations.success') if @block.save(:validate => false)
    else
      if @block.save
        redirect_to blocks_url, notice: t('blocks.destroy_existing_reservations.success')
      else
        # If the block can't save, you will render :new with a list of existing reservations and options
        flash[:error] = t('blocks.destroy_existing_reservations.error')
        render :new, params: params
      end
    end
  end

  # GET /blocks/index_existing_reservations
  def index_existing_reservations
    @existing_reservations = Reservation.find(params[:reservations_to_delete])
  end

private

  def set_block
    @block = Reservation.new(reservation_params)
    @block.user_id = current_user.id
    @block.is_block = true
    @block.title = (params[:reservation][:title].blank?) ? t('blocks.default_title') : params[:reservation][:title]
  end

  def reservation_params
    params.require(:reservation).permit(:room_id, :end_dt, :start_dt, :title)
  end
end
