module RoomsHelper
  
  def default_start_hour
    hours = @room.hours
    unless hours.nil? or hours[:hours_start].nil?
      return hours[:hours_start][:hour].to_i
    end
    return 1
  end
  
  def default_end_hour
    hours = @room.hours
    unless hours.nil? or hours[:hours_end].nil?
      return hours[:hours_end][:hour].to_i
    end
    return 1
  end
  
  def default_start_minute
    hours = @room.hours
    unless hours.nil? or hours[:hours_start].nil?
      return hours[:hours_start][:minute].to_i
    end
    return 0
  end
  
  def default_end_minute
    hours = @room.hours
    unless hours.nil? or hours[:hours_end].nil?
      return hours[:hours_end][:minute].to_i
    end
    return 0
  end
  
  def default_start_ampm
    hours = @room.hours
    unless hours.nil? or hours[:hours_start].nil?
      return hours[:hours_start][:ampm].to_s
    end
    return "am"
  end
  
  def default_end_ampm
    hours = @room.hours
    unless hours.nil? or hours[:hours_end].nil?
      return hours[:hours_end][:ampm].to_s
    end
    return "am"
  end
  
  def display_hours
    hours = @room.hours
    unless hours.nil? or hours[:hours_end].nil?
      "#{hours[:hours_start][:hour]}:#{hours[:hours_start][:minute].to_s.rjust(2, '0')} #{hours[:hours_start][:ampm]} - #{hours[:hours_end][:hour]}:#{hours[:hours_end][:minute].to_s.rjust(2, '0')} #{hours[:hours_end][:ampm]}"
    end
  end

  
end
