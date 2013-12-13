module RoomsHelper
  
  def default_opens_at_hour
    default_hour(@room.opens_at)
  end
  
  def default_closes_at_hour
    default_hour(@room.closes_at)
  end
  
  def default_hour(hours)
    unless hours.nil?
      hour = hours.split(":").first.to_i
      return (hour <= 12) ? (hour == 0) ? 12 : hour : hour - 12
    end
    return 1
  end
  
  def default_opens_at_minute
    default_minute(@room.opens_at)
  end
  
  def default_closes_at_minute
    default_minute(@room.closes_at)
  end
  
  def default_minute(hours)
    return hours.split(":").last.to_i unless hours.nil?
    return 0
  end
  
  def default_opens_at_ampm
    default_ampm(@room.opens_at)
  end
  
  def default_closes_at_ampm
    default_ampm(@room.closes_at)
  end
  
  def default_ampm(hours)
    unless hours.nil?
      hour = hours.split(":").first.to_i
      return (hour < 12) ? "am" : "pm"
    end
    return "am"
  end
  
  def display_hours    
    return (opens_at == closes_at) ? t('room.open_24_hours') : (!opens_at.nil? && !closes_at.nil?) ? "#{opens_at} - #{closes_at}" : ''
  end
  
  def opens_at
    format_hours_time(@room.opens_at)
  end
  
  def closes_at
    format_hours_time(@room.closes_at)
  end
  
  def format_hours_time(hours)
    Time.new(1,1,1,hours.split(":").first.to_i,hours.split(":").last.to_i,0).strftime("%l:%M %P")
  end
  
  def room_group_selected?(room_group)
    (!params[:room].blank? and params[:room][:room_group_id] == room_group.id.to_s) or
      (!@room.room_group.blank? and room_group.id == @room.room_group.id)
  end
  
end
