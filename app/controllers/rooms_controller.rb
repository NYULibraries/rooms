class RoomsController < ApplicationController
  before_filter :authenticate_admin
  respond_to :html, :js
  
  # GET /rooms
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  def show
    @room = Room.find(params[:id])
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
    @room = Room.find(params[:id])
  end

  # POST /rooms
  def create
    @room = Room.new(params[:room])
    hours = { :hours_start => {}, :hours_end => {} }
    unless params[:hours_start].nil?
      hours[:hours_start][:hour] = params[:hours_start][:hour] unless params[:hours_start][:hour].nil?
      hours[:hours_start][:minute] = params[:hours_start][:minute] unless params[:hours_start][:minute].nil?
      hours[:hours_start][:ampm] = params[:hours_start][:ampm] unless params[:hours_start][:ampm].nil?
    end
    unless params[:hours_end].nil?
      hours[:hours_end][:hour] = params[:hours_end][:hour] unless params[:hours_end][:hour].nil?
      hours[:hours_end][:minute] = params[:hours_end][:minute] unless params[:hours_end][:minute].nil?
      hours[:hours_end][:ampm] = params[:hours_end][:ampm] unless params[:hours_end][:ampm].nil?
    end
    @room.hours = hours

    flash[:notice] = 'Room was successfully created.' if @room.save
    respond_with(@room)
  end

  # PUT /rooms/1
  def update
    @room = Room.find(params[:id])
    hours = { :hours_start => {}, :hours_end => {} }
    unless params[:hours_start].nil?
      hours[:hours_start][:hour] = params[:hours_start][:hour] unless params[:hours_start][:hour].nil?
      hours[:hours_start][:minute] = params[:hours_start][:minute] unless params[:hours_start][:minute].nil?
      hours[:hours_start][:ampm] = params[:hours_start][:ampm] unless params[:hours_start][:ampm].nil?
    end
    unless params[:hours_end].nil?
      hours[:hours_end][:hour] = params[:hours_end][:hour] unless params[:hours_end][:hour].nil?
      hours[:hours_end][:minute] = params[:hours_end][:minute] unless params[:hours_end][:minute].nil?
      hours[:hours_end][:ampm] = params[:hours_end][:ampm] unless params[:hours_end][:ampm].nil?
    end
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
  
  # Update the order of the rooms from an ajax request
  def update_order
    @rooms = Room.all

    if params[:rooms]
      params[:rooms].each_with_index do |id, index|
        Room.update_all(['sort_order=?', index+1],['id=?',id])
      end 
    elsif params[:sort_order]
      params[:sort_order].each do |id, index|
        Room.update_all(['sort_order=?', index],['id=?',id])
      end 
    end

    flash[:notice] = 'Room order was successfully updated.'
    respond_with(@rooms) do |format|
      format.js { render :layout => false }
    end
  end
  
end
