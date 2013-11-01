module RoomsHelper
  
  def default_opens_at_hour
    hours = @room.opens_at
    unless hours.nil?
      hour = hours.split(":").first.to_i
      return (hour <= 12) ? (hour == 0) ? 12 : hour : hour - 12
    end
    return 1
  end
  
  def default_closes_at_hour
    hours = @room.closes_at
    unless hours.nil?
      hour = hours.split(":").first.to_i
      return (hour <= 12) ? (hour == 0) ? 12 : hour : hour - 12
    end
    return 1
  end
  
  def default_opens_at_minute
    hours = @room.opens_at
    return hours.split(":").last.to_i unless hours.nil?
    return 0
  end
  
  def default_closes_at_minute
    hours = @room.closes_at
    return hours.split(":").last.to_i unless hours.nil?
    return 0
  end
  
  def default_opens_at_ampm
    hours = @room.opens_at
    unless hours.nil?
      hour = hours.split(":").first.to_i
      return (hour < 12) ? "am" : "pm"
    end
    return "am"
  end
  
  def default_closes_at_ampm
    hours = @room.closes_at
    unless hours.nil?
      hour = hours.split(":").first.to_i
      return (hour < 12) ? "am" : "pm"
    end
    return "am"
  end
  
  def display_hours
    opens_at = Time.new(1,1,1,@room.opens_at.split(":").first.to_i,@room.opens_at.split(":").last.to_i,0).strftime("%l:%M %P")
    closes_at = Time.new(1,1,1,@room.closes_at.split(":").first.to_i,@room.closes_at.split(":").last.to_i,0).strftime("%l:%M %P")
    unless opens_at.nil? or closes_at.nil?
      "#{opens_at} - #{closes_at}"
    end
  end
  
  def room_group_selected?(room_group)
    (!params[:room].blank? and params[:room][:room_group_id] == room_group.id.to_s) or
      (!@room.room_group.blank? and room_group.id == @room.room_group.id)
  end
  
end
