# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def prettify_time(t)
    t_ampm = if t.hour >= 12 then "pm" else "am" end
    t_hour = if t.hour == 0 then 12 elsif t.hour > 12 then t.hour - 12 else '%02d' % t.hour  end
    t_min = '%02d' % t.min 
    t_time =  "<span class=\"hidden-phone\">#{t_hour.to_s}:#{t_min.to_s} #{t_ampm}</span><span class=\"visible-phone\">#{t_hour.to_s}:#{t_min.to_s}</span>"
    return t_time.html_safe
  end
  
  def prettify_date(d)
    d.strftime('%a. %b %d, %Y %I:%M %p')    
  end
  
  def prettify_created_at_date(d)
    d.strftime('%a. %b %d, %Y %I:%M %p')    
  end
  
  def prettify_simple_date(d)
    d.strftime('%m/%d<span class="hidden-phone">/%y</span>').html_safe  
  end
  
  def prettify_dayofweek(d)
    d.strftime('%a')    
  end
  
  def set_default_hour
    if Time.zone.now.strftime("%I").to_i != 12 and Time.zone.now.strftime("%M").to_i >= 30
      return Time.zone.now.strftime("%I").to_i + 1
    elsif Time.zone.now.strftime("%M").to_i < 30
      return Time.zone.now.strftime("%I").to_i
    else
      return 1
    end
  end
  
  def set_default_minute
    if Time.zone.now.strftime("%M").to_i >= 0 and Time.zone.now.strftime("%M").to_i <= 29
     return 30
   else
     return 0
   end
  end
  
  def set_default_ampm
    if Time.zone.now.strftime("%H").to_i == 11 and Time.zone.now.strftime("%M").to_i >= 30 
      return (Time.zone.now.strftime("%p").downcase == "am") ? "pm" : "am"
    else
      return Time.zone.now.strftime("%p").downcase
    end
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
      
      status_search = Reservation.search do 
        query do
          filtered do 
            filter :term, :room_id => room.id
            filter :term, :deleted => false
            filter :term, :is_block => false
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
      status = status_search.first

  		# Disable radio button if classroom is in use at this time
  		return true if !status.blank? 
    end
    return false
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
  
  # Generate link to sorting action
  def sortable(column, title = nil, url_options = {}, remote = false)
    title ||= column.titleize
    css_class = column == sort_column.to_sym ? "current #{sort_direction}" : nil
    direction = column == sort_column.to_sym && sort_direction == "asc" ? "desc" : "asc"
    direction_icon = (direction.eql? "desc") ? :sort_desc : :sort_asc
    search = params[:search]
    html = link_to title, params.merge(:sort => column, :direction => direction, :id => "").merge(url_options), {:data => {:remote => true}, :class => css_class}
    html << icon_tag(direction_icon) if column == sort_column.to_sym
    return html
  end
  
  def get_formatted_text(t, css = nil)
    simple_format(get_sanitized_detail(t), :class => css)
  end
  
  def get_sanitized_detail(t)
    sanitize(t, :tags => %w(b strong i em br p a ul li), :attributes => %w(target href class))
  end
  
  # Generate an abbr tag for long words
  def word_break word, break_at = 10
    if word.length > break_at
      content_tag :abbr, truncate(word, :length => 10), :title => word
    else
      word
    end
  end
end
