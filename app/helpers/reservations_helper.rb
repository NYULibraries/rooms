module ReservationsHelper
  
  def construct_grid_data(room)
    
    html = ""
    @times.each do |t|
	    t_today = Time.now.strftime('%Y%m%d').to_i #today's date
	    t_now = Time.now.strftime('%H%M').to_i #local time
	    t_this_date = t.strftime('%Y%m%d').to_i #this iteration's date
	    t_this_time = t.strftime('%H%M').to_i #this iteration's time
	    t_next = t + 30.minutes #next iteration's time
	    is_in_past = (t_today == t_this_date && t_this_time < t_now)
	    r_is_open = room_is_open(room,t)
	    
	    @status = Reservation.active_with_blocks.find(:all, :conditions => ["room_id = ? AND ((start_dt >= ? AND end_dt <= ?) OR (start_dt <= ? AND end_dt >= ?))", room.id, t, t_next, t, t_next], :limit => 1)
      existing_res = @status.first

	    html += "<td valign=\"top\" class=\""
	    (!@status.blank? or is_in_past or !r_is_open) ? html += "timeslot_unavailable" : html += "timeslot_available"	  
	    html += " timeslot_selected" if t >= @start_dt && t < @end_dt
	    html += "\">"
	    html += "<a href=\"#{user_path(existing_res.user_id)}?highlight[]=#{existing_res.id}\##{existing_res.id}\" class=\"reservation_whois\" target=\"_blank\">#{icon_tag :info}</a>" if is_admin? and !@status.empty? and !existing_res.is_block
	    html += "<a class=\"preview_link\" target=\"_blank\" title=\"Room is closed\" alt=\"Room is closed\">#{icon_tag :warning}</a>" if !r_is_open
	    html += "<a class=\"preview_link\" target=\"_blank\" title=\"#{existing_res.title unless existing_res.title.blank?}\" alt=\"#{existing_res.title unless existing_res.title.blank?}\">#{icon_tag :warning}</a>" if r_is_open and !@status.empty? and existing_res.is_block
	    html += "</td>"
	  end
	
	  return html.html_safe
  end
  
  def get_past_reservations(config)
    t_now = DateTime.now
    @reservations_deleted = Reservation.deleted.where("user_id = ? AND start_dt > ?", @user.id, t_now - config[:how_far_back].call)
    @reservations_past = Reservation.active_non_blocks.where("user_id = ? AND end_dt <= ? AND start_dt > ?", @user.id, t_now, t_now - config[:how_far_back].call)
    @reservations = Reservation.active_non_blocks.where("user_id = ? AND end_dt > ?", @user.id, t_now)
  end
  
  def get_times_array(padding = true)
    # create an array of times starting one hour before the selected start hour
    @times = (padding) ? [@start_dt - 1.hour] : [@start_dt]
   
    # and including every 1/2 hour until one hour after the selected end time
    while true do
      tmp = @times.last + 30.minutes
      (padding) ? (tmp == (@end_dt + 1.hour)) ? break : '' : (tmp == @end_dt) ? break : ''
      @times.push(tmp)
    end
  end
  
  def construct_grid_headers 
    html = ""
    previous_day = nil
    @times.each do |t|
      html += "<th class=\" date-cell\">"
      html += prettify_dayofweek(t)
      html += "<br />"
      html += "<span class=\"same_day\">" if t.day == previous_day
      html += prettify_simple_date(t).to_s
      html += "</span>" if t.day == previous_day
      html += "<br />"
      html += prettify_time(t).to_s
      html += "</th>"
      previous_day = t.day
    end
    
    return html.html_safe
  end
  
  def highlight(reservation)
    (!params[:highlight].blank? and params[:highlight].include? reservation.id.to_s) ? 'warning' : ''
  end
  
  def get_deleted_by(r,user)
    deleted = r.deleted_by.to_hash
    h = ""
    unless deleted.nil?
      if !deleted[:by_user].nil?
        deleted_by = deleted[:by_user]
        if deleted_by == user.id
          h += "User"
        else
          h += "Admin (<a href=\"#{user_path(deleted_by)}\">#{User.find(deleted_by).username}</a>)".html_safe
        end
      elsif !deleted[:by_block].nil? and deleted[:by_block]
        h += "<a href=\"#{blocks_path}\">Block</a>".html_safe
      end
    end
    return h
  end
  
  def room_type_options
    Room.where("type_of_room IS NOT NULL and type_of_room != ''").uniq.pluck(:type_of_room)
  end
  
  def college_name_options
    colleges = []
    users = User.find(:all, :conditions => "user_attributes LIKE '%college_name%'")
    users.each do |p|
      user_attributes = p.user_attributes
      colleges.push(user_attributes[:college_name]) unless colleges.include? user_attributes[:college_name] or user_attributes[:college_name].blank?
    end
    colleges
  end
  
  def college_code_options
    college_codes = []
    users = User.find(:all, :conditions => "user_attributes LIKE '%college_code%'")
    users.each do |p|
      user_attributes = p.user_attributes
      college_codes.push(user_attributes[:college_code]) unless college_codes.include? user_attributes[:college_code] or user_attributes[:college_code].blank?
    end
    college_codes
  end
  
  def dept_options
    depts = []
    users = User.find(:all, :conditions => "user_attributes LIKE '%dept_name%'")
    users.each do |p|
      user_attributes = p.user_attributes
      depts.push(user_attributes[:dept_name]) unless depts.include? user_attributes[:dept_name] or user_attributes[:dept_name].blank?
    end
    depts
  end
  
  def major_options
    majors = []
    users = User.find(:all, :conditions => "user_attributes LIKE '%major%'")
    users.each do |p|
      user_attributes = p.user_attributes
      majors.push(user_attributes[:major]) unless majors.include? user_attributes[:major] or user_attributes[:major].blank?
    end
    majors
  end
  
  def user_status_options
    user_statuses = []
    users = User.find(:all, :conditions => "user_attributes LIKE '%bor_status%'")
    users.each do |p|
      user_attributes = p.user_attributes
      user_statuses.push(user_attributes[:bor_status]) unless user_statuses.include? user_attributes[:bor_status] or user_attributes[:bor_status].blank?
    end
    user_statuses
  end
  
end
