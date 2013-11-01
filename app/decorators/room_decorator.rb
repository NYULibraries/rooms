class RoomDecorator < Draper::Decorator
  delegate_all
  
  ##
  # Return Tire result from idnex where reservation falls within the given timeslot
  #
  # = Example
  #
  #   @room.find_reservation_by_timeslot(DateTime.now)
  def find_reservation_by_timeslot(timeslot)
    
    t_next = timeslot + 30.minutes #next iteration's time
    timeslot = timeslot
    room_id = model.id
    
    reservation ||= Reservation.tire.search do 
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
      size 1
    end
    return reservation.results.first
  end
  
  def is_open?(timeslot)
    # Base case: room is open is hours are missing or equal
    return true if (model.opens_at.blank? or model.closes_at.blank?) or (model.opens_at == model.closes_at)
    # Format hour strings as comparable times
    opens_at = Time.new(1,1,1,model.opens_at.split(":").first.to_i,model.opens_at.split(":").last,0,0)
    closes_at = Time.new(1,1,1,model.closes_at.split(":").first.to_i,model.closes_at.split(":").last,0,0)
    current_timeslot = Time.new(1,1,1,timeslot.strftime('%H').to_i,timeslot.strftime('%M').to_i,0,0)
    # If closes_at comes before opens_at e.g. hours are 7am-2am, 
    # then return true if current timeslot is less than closes_at, e.g. 12am, 1am
    return true if (closes_at < opens_at and current_timeslot < closes_at)
    # Add 24 hours
    closes_at = (closes_at < opens_at) ? closes_at + 24.hours : closes_at
    return ((opens_at <= current_timeslot) and (current_timeslot < closes_at))
  end
  
  ##
  # Convenience method for the opposite of is_open?
  def is_closed?(timeslot)
    !self.is_open?(timeslot)
  end
end
