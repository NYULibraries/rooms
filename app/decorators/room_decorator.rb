class RoomDecorator
  attr_accessor :room

  def initialize(room)
    @room = room
  end

  # Catch-all for all the Room attributes we're delegating but don't want to specify
  # TODO: This is lazy and will cause debugging issues
  def method_missing(sym, *args, &block)
    room.send(sym, *args, &block)
  end

  ##
  # Return Tire result from idnex where reservation falls within the given timeslot
  #
  # = Example
  #
  #   @room.find_reservation_by_timeslot(DateTime.now, existing_reservations)
  def find_reservation_by_timeslot(timeslot, existing_reservations)
    t_next = timeslot + 30.minutes #next iteration's time
    timeslot = timeslot

    # Get existing reservations in this room from previously queried elasticsearch result
    room_reservations = existing_reservations.find {|r| r[id.to_i]}
    unless room_reservations.blank?
      # Return a has with the reservation information if it is found in the collection of reservations for this room in this timeslot
      reservation = room_reservations[id.to_i].find {|r| (r._source.start_dt.to_datetime >= timeslot and r._source.end_dt.to_datetime <= t_next) or (r._source.start_dt.to_datetime <= timeslot and r._source.end_dt.to_datetime >= t_next) }
      return reservation
    end

  end

  def is_open?(timeslot)
    # Base case: room is open is hours are missing or equal
    return true if (opens_at.blank? or closes_at.blank?) or (opens_at == closes_at)
    # If closes_at comes before opens_at e.g. hours are 7am-2am,
    # then return true if current timeslot is less than closes_at, e.g. 12am, 1am
    return true if (closes_at_comparable < opens_at_comparable and current_timeslot_comparable(timeslot) < closes_at_comparable)
    # Add 24 hours
    closes_at = (closes_at_comparable < opens_at_comparable) ? closes_at_comparable + 24.hours : closes_at_comparable
    return ((opens_at_comparable <= current_timeslot_comparable(timeslot)) and (current_timeslot_comparable(timeslot) < closes_at))
  end

  ##
  # Convenience method for the opposite of is_open?
  def is_closed?(timeslot)
    !self.is_open?(timeslot)
  end

  def closes_at_comparable
    closes_at_comparable ||= comparable_room_hours(closes_at)
  end

  def opens_at_comparable
    opens_at_comparable ||= comparable_room_hours(opens_at)
  end

  def comparable_room_hours(hours)
    Time.new(1,1,1,hours.split(":").first.to_i,hours.split(":").last,0,0)
  end

  def current_timeslot_comparable(timeslot)
    current_timeslot_comparable ||= Time.new(1,1,1,timeslot.strftime('%H').to_i,timeslot.strftime('%M').to_i,0,0)
  end
end
