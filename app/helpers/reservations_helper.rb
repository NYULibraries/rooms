module ReservationsHelper
  
  # Display each 1/2 slot as a table data cell
  # * Show as red if room is booked (by user or block), in the past or closed (according to hours)
  # * Show as green if a valid time to book with no restrictions
  def construct_grid_data(room)
    html = ""
    times_array.each do |timeslot|
	    t_next = timeslot + 30.minutes #next iteration's time
	    
      reservation = reservation_search(timeslot, t_next, room.id).first

      html += content_tag(:td, :class => timeslot_class(reservation, room, timeslot)) do 
        if @user.is_admin? and !reservation.nil? and !reservation.is_block
          link_to(icon_tag(:info), user_path(reservation.user_id, :params => {:highlight => [reservation.id]}, :anchor => reservation.id), :title => "Room is booked", :alt => "Room is booked", :class => "preview_link reservation_whois", :target => "_blank") 
        elsif !room_is_open?(room, timeslot)
          link_to(icon_tag(:warning), "#", :title => "Room is closed", :alt => "Room is closed", :class => "preview_link", :target => "_blank")
        elsif room_is_open?(room, timeslot) and !reservation.nil? and reservation.is_block
          reservation_from_db = reservation.load
          link_to(icon_tag(:warning), "#", :title => reservation_from_db.title, :alt => reservation_from_db.title, :class => "preview_link", :target => "_blank") 
        end
      end
	  end
	 
	  return html.html_safe
  end
  
  # Logic for when to disable the reservation radio button in the availability form
  #
  # * Return true if the room is closed during selected hour and skip search for existing reservations
  # * Return true if current classroom is in use at the selected time
  # * Return true if time is in the past
  # * Otherwise return false, button is not disabled 
  def disable_reservation_button(room)
    times = [start_dt]
    while true do
      tmp = times.last + 30.minutes
      break if tmp == (end_dt)
      times.push(tmp)
    end
    
    times.each do |timeslot|
  		t_next = timeslot + 30.minutes
      
      #Return true if the room is closed during this hour and forgo search for existing reservations
      return true if is_in_past?(timeslot) or !room_is_open?(room,timeslot)
      
  		# Disable radio button if classroom is in use at this time
  		return true if !reservation_search(timeslot, t_next, room.id).empty? 
    end
    return false
  end
  
  # ElasticSearch search to find if a reservation exists in a given timeslot
  def reservation_search(timeslot, t_next, room_id)
    return Reservation.search do 
      query do
        filtered do 
          filter :term, :room_id => room_id
          filter :term, :deleted => false
          filter :or, 
            { :and => [
                { :range => { :start_dt => { :gte => timeslot } } },
                { :range => { :end_dt => { :lte => t_next } } }
            ]},
            { :and => [
                { :range => { :start_dt => { :lte => timeslot } } },
                { :range => { :end_dt => { :gte => t_next } } }
            ]}
        end
      end
      size 1
    end
  end
  
  # Find if the room (r) is open during the timeslot (t)
  def room_is_open?(room,t)
    r = room.load
    t_as_time = t.strftime('%H%M').to_i
    unless r.hours.nil? or r.hours[:hours_start].nil? or r.hours[:hours_end].nil? or (r.hours[:hours_end] == r.hours[:hours_start])
      #Parse our start and end hour and add 12 to the hour if in PM
      hour_start = (r.hours[:hours_start][:ampm].to_s == "am") ?  
                      (r.hours[:hours_start][:hour].to_i == 12) ? 0 : r.hours[:hours_start][:hour].to_i : 
                          (r.hours[:hours_start][:hour].to_i == 12) ? r.hours[:hours_start][:hour].to_i : r.hours[:hours_start][:hour].to_i + 12
      hour_end = (r.hours[:hours_end][:ampm].to_s == "am") ?  
                    (r.hours[:hours_end][:hour].to_i == 12) ? 0 : r.hours[:hours_end][:hour].to_i : 
                      (r.hours[:hours_end][:hour].to_i == 12) ? r.hours[:hours_end][:hour].to_i : r.hours[:hours_end][:hour].to_i + 12
      #Create dates and format them as comparable integers
      open_time = DateTime.new(1,1,1,hour_start,r.hours[:hours_start][:minute].to_i).strftime('%H%M').to_i
      close_time = DateTime.new(1,1,1,hour_end,r.hours[:hours_end][:minute].to_i).strftime('%H%M').to_i
      #If close time is before opening time (i.e. hours wrap back around to am) 
      #and current time is less than the closing time return true
      return true if close_time < open_time and t_as_time < close_time
      #Some processing for wraparound hours
      close_time = (close_time < open_time) ? close_time + 2400 : close_time
      #See if current time (t) is between opening and closing
      return (t_as_time >= open_time and t_as_time < close_time)
    end
    #The room is always open if there are no hours set up
    return true
  end
  
  # Get the css classes to color-code availability grid
  def timeslot_class(reservation, room, timeslot)
    timeslot_class = (!reservation.blank? or is_in_past?(timeslot) or !room_is_open?(room, timeslot)) ? "timeslot_unavailable" : "timeslot_available"	  
    timeslot_class += " timeslot_selected" if timeslot >= start_dt && timeslot < end_dt
    return timeslot_class
  end
  
  # Return true if the :timeslot: is in the past, and false otherwise
  def is_in_past?(timeslot)
    return (timeslot.strftime("%Y-%m-%d %H:%M").to_datetime <= Time.zone.now.strftime("%Y-%m-%d %H:%M").to_datetime)
  end

  def times_array(padding = true)
    @times_array ||= get_times_array(padding)
  end
  
  # Generate an instance variable with an array of times starting one hour before the selected start hour
  # if padding is true. If padding is false, just return array of selected times.
  def get_times_array(padding = true)
    times = (padding) ? [start_dt - 1.hour] : [start_dt]
   
    # and including every 1/2 hour until one hour after the selected end time
    while true do
      tmp = times.last + 30.minutes
      (padding) ? (tmp == (end_dt + 1.hour)) ? break : '' : (tmp == end_dt) ? break : ''
      times.push(tmp)
    end
    return times
  end

  # Get information about who deleted the given reservation
  def get_deleted_by(reservation)
    if reservation.deleted?
      if !reservation.deleted_by[:by_user].nil?
        deleted_by = reservation.deleted_by[:by_user]
        if deleted_by == reservation.user.id
          "User"
        else
          link_to "Admin", user_path(deleted_by)
        end
      elsif reservation.deleted_by[:by_block]
        link_to "Block", blocks_path
      end
    end
  end

end
