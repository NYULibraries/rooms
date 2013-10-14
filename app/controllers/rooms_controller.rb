class RoomsController < ApplicationController
  authorize_resource
  respond_to :html, :js
  
  # GET /rooms
  def index
    options = { :direction => (params[:direction] || 'asc'), :sort => (params[:sort] || sort_column.to_sym), :page => (params[:page] || 1), :per => (params[:per] || 20) }  
    # Get Rooms from ElasticSearch through tire DSL
    tire_params = params
    @rooms = Room.tire.search do
      query { string tire_params[:q] } unless tire_params[:q].blank?
      sort { by options[:sort], options[:direction] }
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
    respond_with(@room)
  end

  # GET /rooms/1/edit
  def edit
    @room = Room.find(params[:id])
    respond_with(@room)
  end

  # POST /rooms
  def create
    @room = Room.new(params[:room])   
    @room.hours = hours

    flash[:notice] = 'Room was successfully created.' if @room.save
    respond_with(@room)
  end

  # PUT /rooms/1
  def update
    @room = Room.find(params[:id])
    @room.hours = hours
     
    flash[:notice] = 'Room was successfully updated.' if @room.update_attributes(params[:room])
    respond_with(@room)
  end

  # DELETE /rooms/1
  def destroy
    @room = Room.find(params[:id])
    @room.destroy
    
    respond_with(@room)
  end
  
  # GET /rooms/sort
  # Get rooms for sorting
  def index_sort
    @rooms = Room.all

    respond_with(@rooms)
  end

  # PUT /rooms/sort  
  # Update sort order of rooms
  def update_sort
    @rooms = Room.all
    
    params[:rooms].each_with_index do |id, index|
      Room.update_all(['sort_order=?', index+1],['id=?',id])
    end 
    # And then reindex

    flash[:notice] = 'Room order was successfully updated.'
    respond_with(@rooms)
  end
  
  # Implement sort column function for this model
  def sort_column
    super "Room", "sort_order"
  end
  helper_method :sort_column
  
private

  # Convert hours parameter to a hash
  def hours
    @hours ||= { 
      :hours_start => {
        :hour => params[:hours_start][:hour],
        :minute => params[:hours_start][:minute],
        :ampm => params[:hours_start][:ampm]
      }, 
      :hours_end => {
        :hour => params[:hours_end][:hour],
        :minute => params[:hours_end][:minute],
        :ampm => params[:hours_end][:ampm]
      } 
    }
  end
  
end
