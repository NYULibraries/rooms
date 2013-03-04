module ReservationsHelper
  
  # Display each 1/2 slot as a table data cell
  # * Show as red if room is booked (by user or block), in the past or closed (according to hours)
  # * Show as green if a valid time to book with no restrictions
  def construct_grid_data(room)
    html = ""
    @times.each do |timeslot|
	    t_next = timeslot + 30.minutes #next iteration's time
	    
	    reservation = Reservation.active_with_blocks.where("room_id = ? AND ((start_dt >= ? AND end_dt <= ?) OR (start_dt <= ? AND end_dt >= ?))", room.id, timeslot, t_next, timeslot, t_next).first
      html += content_tag(:td, :class => timeslot_class(reservation, room, timeslot)) do 
        if is_admin? and !reservation.nil? and !reservation.is_block
          link_to(icon_tag(:info), user_path(reservation.user_id, :params => {:highlight => [reservation.id]}, :anchor => reservation.id), :title => "Room is booked", :alt => "Room is booked", :class => "preview_link reservation_whois", :target => "_blank") 
        elsif !room_is_open?(room, timeslot)
          link_to(icon_tag(:warning), "#", :title => "Room is closed", :alt => "Room is closed", :class => "preview_link", :target => "_blank")
        elsif room_is_open?(room, timeslot) and !reservation.nil? and reservation.is_block
          link_to(icon_tag(:warning), "#", :title => reservation.title, :alt => reservation.title, :class => "preview_link", :target => "_blank") 
        end
      end
	  end
	
	  return html.html_safe
  end
  
  # Get the css classes to color-code availability grid
  def timeslot_class(reservation, room, timeslot)
    timeslot_class = (!reservation.blank? or is_in_past?(timeslot) or !room_is_open?(room, timeslot)) ? "timeslot_unavailable" : "timeslot_available"	  
    timeslot_class += " timeslot_selected" if timeslot >= @start_dt && timeslot < @end_dt
    return timeslot_class
  end
  
  # Return true if the :timeslot: is in the past, and false otherwise
  def is_in_past?(timeslot)
    t_today = Time.now.strftime('%Y%m%d').to_i #today's date
    t_now = Time.now.strftime('%H%M').to_i #local time
    t_this_date = timeslot.strftime('%Y%m%d').to_i #this iteration's date
    t_this_time = timeslot.strftime('%H%M').to_i #this iteration's time
    return ((t_today == t_this_date and t_this_time <= t_now) or (t_this_date < t_today))
  end
  
  # Generate an instance variable with and array of times starting one hour before the selected start hour
  # if padding is true. If padding is false, just return array of selected times.
  def get_times_array(padding = true)
    @times = (padding) ? [@start_dt - 1.hour] : [@start_dt]
   
    # and including every 1/2 hour until one hour after the selected end time
    while true do
      tmp = @times.last + 30.minutes
      (padding) ? (tmp == (@end_dt + 1.hour)) ? break : '' : (tmp == @end_dt) ? break : ''
      @times.push(tmp)
    end
  end

  # Set a class to highlight item if this ID is selected in query string parameters
  def highlight(reservation)
    (!params[:highlight].blank? and params[:highlight].include? reservation.id.to_s) ? 'warning' : ''
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
  
  def room_type_options
    Room.where("type_of_room IS NOT NULL and type_of_room != ''").uniq.pluck(:type_of_room)
  end
  
  def college_name_options
    colleges = []
    users = User.where("user_attributes LIKE '%college_name%'")
    users.each do |p|
      user_attributes = p.user_attributes
      colleges.push(user_attributes[:college_name]) unless colleges.include? user_attributes[:college_name] or user_attributes[:college_name].blank?
    end
    colleges
  end
  
  def college_code_options
    college_codes = []
    users = User.where("user_attributes LIKE '%college_code%'")
    users.each do |p|
      user_attributes = p.user_attributes
      college_codes.push(user_attributes[:college_code]) unless college_codes.include? user_attributes[:college_code] or user_attributes[:college_code].blank?
    end
    college_codes
  end
  
  def dept_options
    depts = []
    users = User.where("user_attributes LIKE '%dept_name%'")
    users.each do |p|
      user_attributes = p.user_attributes
      depts.push(user_attributes[:dept_name]) unless depts.include? user_attributes[:dept_name] or user_attributes[:dept_name].blank?
    end
    depts
  end
  
  def major_options
    majors = []
    users = User.where("user_attributes LIKE '%major%'")
    users.each do |p|
      user_attributes = p.user_attributes
      majors.push(user_attributes[:major]) unless majors.include? user_attributes[:major] or user_attributes[:major].blank?
    end
    majors
  end
  
  def user_status_options
    user_statuses = []
    users = User.where("user_attributes LIKE '%bor_status%'")
    users.each do |p|
      user_attributes = p.user_attributes
      user_statuses.push(user_attributes[:bor_status]) unless user_statuses.include? user_attributes[:bor_status] or user_attributes[:bor_status].blank?
    end
    user_statuses
  end
  
end
