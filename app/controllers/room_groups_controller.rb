class RoomGroupsController < ApplicationController
  load_and_authorize_resource
  respond_to :html, :js

  def index
    @room_groups = RoomGroup.sorted(params[:sort], "title asc").page(params[:page]).per(30)
    respond_with(@room_groups)
  end

  def show
    @room_group = RoomGroup.find(params[:id])
    respond_with(@room_group)
  end

  def new
    @room_group = RoomGroup.new
    respond_with(@room_group)
  end

  def create
    @room_group = RoomGroup.new(room_group_params)
    flash[:success] = t('room_groups.create.success') if @room_group.save
    respond_with(@room_group)
  end

  def edit
    @room_group = RoomGroup.find(params[:id])
    respond_with(@room_group)
  end

  def update
    @room_group = RoomGroup.find(params[:id])
    flash[:success] = t('room_groups.update.success') if @room_group.update_attributes(room_group_params)
    respond_with(@room_group)
  end

  def destroy
    @room_group = RoomGroup.find(params[:id])
    @room_group.destroy
    respond_with(@room_group)
  end

  def sort_column
    super "RoomGroup", "title"
  end
  helper_method :sort_column

  private

  def room_group_params
    params.require(:room_group).permit(:title, :code, admin_roles: [])
  end
end
