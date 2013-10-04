module ReservationsHelper
  
  # Display each 1/2 slot as a table data cell
  # * Show as red if room is booked (by user or block), in the past or closed (according to hours)
  # * Show as green if a valid time to book with no restrictions
  def construct_grid_data(room)
    html = ""
    times_array.each do |timeslot|
	    t_next = timeslot + 30.minutes #next iteration's time
	    
	    reservation_search = Reservation.search do 
        query do
          filtered do 
            filter :term, :deleted => false
            filter :term, :room_id => room.id
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
      reservation = reservation_search.first

      html += content_tag(:td, :class => timeslot_class(reservation, room, timeslot)) do 
        if @user.is? :admin and !reservation.nil? and !reservation.is_block
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
    timeslot_class += " timeslot_selected" if timeslot >= start_dt && timeslot < end_dt
    return timeslot_class
  end
  
  # Return true if the :timeslot: is in the past, and false otherwise
  def is_in_past?(timeslot)
    return (timeslot.strftime("%Y-%m-%d %H:%M").to_datetime <= Time.zone.now.strftime("%Y-%m-%d %H:%M").to_datetime)
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
  
  def times_array(padding = true)
    @times_array ||= get_times_array(padding)
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
    @room_types ||= Rails.cache.fetch "room_types", :expires_in => 30.days do
      Room.where("type_of_room IS NOT NULL and type_of_room != ''").uniq.pluck(:type_of_room)
    end
  end
  
  def college_name_options
    colleges = []
    @user_college_names ||= Rails.cache.fetch "user_college_names", :expires_in => 30.days do
      User.where("user_attributes LIKE '%college_name%'").uniq.pluck(:user_attributes)
    end
    @user_college_names.each do |p|
      colleges.push(p[:college_name]) unless colleges.include? p[:college_name] or p[:college_name].blank?
    end
    colleges
  end
  
  def college_code_options
    college_codes = []
    @user_college_codes ||= Rails.cache.fetch "user_college_codes", :expires_in => 30.days do
      User.where("user_attributes LIKE '%college_code%'").uniq.pluck(:user_attributes)
    end
    @user_college_codes.each do |p|
      college_codes.push(p[:college_code]) unless college_codes.include? p[:college_code] or p[:college_code].blank?
    end
    college_codes
  end
  
  def dept_options
    depts = []
    @user_dept_names ||= Rails.cache.fetch "user_dept_names", :expires_in => 30.days do
      User.where("user_attributes LIKE '%dept_name%'").uniq.pluck(:user_attributes)
    end
    @user_dept_names.each do |p|
      depts.push(p[:dept_name]) unless depts.include? p[:dept_name] or p[:dept_name].blank?
    end
    depts
  end
  
  def major_options
    majors = []
    @user_majors ||= Rails.cache.fetch "user_majors", :expires_in => 30.days do
      User.where("user_attributes LIKE '%major%'").uniq.pluck(:user_attributes)
    end
    @user_majors.each do |p|
      majors.push(p[:major]) unless majors.include? p[:major] or p[:major].blank?
    end
    majors
  end
  
  def user_status_options
    user_statuses = []
    @user_bor_statuses ||= Rails.cache.fetch "user_bor_statuses", :expires_in => 30.days do
      User.where("user_attributes LIKE '%bor_status%'").uniq.pluck(:user_attributes)
    end
    @user_bor_statuses.each do |p|
      user_statuses.push(p[:bor_status]) unless user_statuses.include? p[:bor_status] or p[:bor_status].blank?
    end
    user_statuses
  end
  
end
