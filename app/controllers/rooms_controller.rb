class RoomsController < ApplicationController
  load_and_authorize_resource
  respond_to :html, :js

  # GET /rooms
  def index
    @room_groups = RoomGroup.all
    # Default elasticsearch options
    options = params.merge(default_elasticsearch_options)
    # Get room groups this user can admin
    room_group_filter = (params[:room_group].blank?) ? @room_groups.map(&:code).reject { |r| cannot? r.to_sym, RoomGroup } : [params[:room_group]]
    # Boolean if this is default sort or a re-sort
    resort = (sort_column.to_sym == options[:sort])
    # Elasticsearch DSL
    @rooms = Elasticsearch::DSL::Search.search do
      query { string options[:q] } unless options[:q].blank?
      filter :terms, :room_group => room_group_filter, :execution => "or"
      sort do
        by :room_group, 'asc'
        by options[:sort], options[:direction]
      end if resort
      sort { by options[:sort], options[:direction] } unless resort
      page = options[:page].to_i
      search_size = options[:per].to_i
      from (page -1) * search_size
      size search_size
    end
    respond_with(@rooms)
  end

  # GET /rooms/1
  def show
    @room = Room.find(params[:id])
    respond_with(@room)
  end

  # GET /rooms/new
  def new
    @room = Room.new
    @room_groups = RoomGroup.all
    respond_with(@room)
  end

  # GET /rooms/1/edit
  def edit
    @room = Room.find(params[:id])
    @room_groups = RoomGroup.all
    respond_with(@room)
  end

  # POST /rooms
  def create
    @room_groups = RoomGroup.all
    @room = Room.new(create_params)
    @room.opens_at = opens_at
    @room.closes_at = closes_at

    flash[:notice] = t("rooms.create.success") if @room.save
    respond_with(@room)
  end

  # PUT /rooms/1
  def update
    @room_groups = RoomGroup.all
    @room = Room.find(params[:id])
    @room.opens_at = opens_at
    @room.closes_at = closes_at

    flash[:notice] = t("rooms.update.success") if @room.update_attributes(update_params)
    respond_with(@room)
  end

  # DELETE /rooms/1
  def destroy
    @room = Room.find(params[:id])
    @room.destroy

    respond_with(@room)
  end

  # GET /rooms/sort
  def index_sort
    @rooms = Room.accessible_by(current_ability).joins(:room_group).reorder("room_groups.code asc",sort_column.to_sym)
    @rooms = @rooms.where(:room_groups => {:code => params[:room_group]}) unless params[:room_group].blank?

    respond_with(@rooms)
  end

  # PUT /rooms/sort
  def update_sort
    @rooms = Room.accessible_by(current_ability).joins(:room_group).reorder("room_groups.code asc",sort_column.to_sym)
    @rooms = @rooms.where(:room_groups => {:code => params[:room_group]}) unless params[:room_group].blank?

    # Have to iterate through each room in order to reindex sort order
    # Could be a scalability issue moving forward
    params[:rooms].each_with_index do |id, index|
      room = Room.find(id)
      room.sort_order = index+1
      room.save
    end

    flash[:notice] = t("rooms.update_sort.success")

    respond_with(@rooms, :location => sort_rooms_url)
  end

  # Implement sort column function for this model
  def sort_column
    super "Room", "sort_order"
  end
  helper_method :sort_column

private

  def opens_at
    @opens_at ||= format_new_time(:opens_at)
  end

  def closes_at
    @closes_at ||= format_new_time(:closes_at)
  end

  def format_new_time(time_params)
    hour_method = ([:opens_at, :closes_at].include? time_params) ? send("#{time_params.to_s}_hour") : 0
    return Time.new(1,1,1,hour_method,params[time_params][:minute],0,0).strftime("%k:%M")
  end

  def opens_at_hour
    @opens_at_hour ||= get_hour_in_24(params[:opens_at])
  end

  def closes_at_hour
    @closes_at_hour ||= get_hour_in_24(params[:closes_at])
  end

  def create_params
    params.require(:room).permit(:room_group_id, :title, :type_of_room, :collaborative, :description, :size_of_room, :image_link)
  end

  def update_params
    params.require(:room).permit(:title, :type_of_room, :collaborative, :description, :size_of_room, :image_link)
  end

end
