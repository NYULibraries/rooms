module ReservationsHelper

  # Display each 1/2 slot as a table data cell
  # * Show as red if room is booked (by user or block), in the past or closed (according to hours)
  # * Show as green if a valid time to book with no restrictions
  def construct_grid_data(room)
    html = ""

    times_array.each do |timeslot|
      reservation = room.find_reservation_by_timeslot(timeslot, @existing_reservations)

      html += content_tag(:td, :class => timeslot_class(reservation, room, timeslot)) do #, :colspan => (timeslot == times_array[0] || timeslot == times_array[-1]) ? 2 : 1) do
        if @user.is_admin? and !reservation.blank? and !reservation._source.is_block
          link_to(icon_tag(:info), user_path(reservation._source.user_id, :params => {:highlight => [reservation._source.id]}, :anchor => reservation._source.id), :title => "Room is booked", :alt => "Room is booked", :class => "preview_link reservation_whois", :target => "_blank")
        elsif room.is_closed? timeslot
          link_to(icon_tag(:warning), '#', :title => "Room is closed", :alt => "Room is closed", :class => "preview_link", :target => "_blank")
        elsif room.is_open? timeslot and !reservation.blank? and reservation._source.is_block
          link_to(icon_tag(:warning), '#', :title => reservation._source.title, :alt => reservation._source.title, :class => "preview_link", :target => "_blank")
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
    selected_times.each do |timeslot|
      #Return true if the room is closed during this hour and forgo search for existing reservations
      return true if is_in_past?(timeslot) or room.is_closed?(timeslot)

  		# Disable radio button if classroom is in use at this time
  		return true if !room.find_reservation_by_timeslot(timeslot, @existing_reservations).blank?
    end
    return false
  end

  ##
  # Check the radio button for this room if it is selected
  def check_reservation_button(room)
    (!params[:reservation].blank? && params[:reservation][:room_id] == room.id)
  end

  # Get the css classes to color-code availability grid
  def timeslot_class(reservation, room, timeslot)
    timeslot_class = "timeslot"
    timeslot_class += (!reservation.blank? or is_in_past?(timeslot) or room.is_closed?(timeslot)) ? " timeslot_unavailable" : " timeslot_available"
    timeslot_class += " timeslot_preferred" if timeslot >= start_dt && timeslot < end_dt
    timeslot_class += " timeslot_preferred_first" if timeslot == start_dt
    timeslot_class += " timeslot_preferred_last" if (timeslot + 30.minutes) == end_dt
    return timeslot_class
  end

  # Return true if the :timeslot: is in the past, and false otherwise
  def is_in_past?(timeslot)
    (timeslot.strftime("%Y-%m-%d %H:%M").to_datetime <= Time.zone.now.strftime("%Y-%m-%d %H:%M").to_datetime)
  end

  # Times array with padding
  def times_array(padding = true)
    @times_array ||= get_times_array(padding)
  end

  def dates_array
    @dates_array ||= times_array.group_by {|t| t.to_date}
  end

  # Times array of only selected times
  def selected_times
    @selected_times ||= get_times_array(false)
  end

  # Generate an array of times starting one hour before the selected start hour
  # if padding is true. If padding is false, just return array of selected times.
  def get_times_array(padding = true)
    times = (padding) ? [start_dt - 1.hour] : [start_dt]

    # and including every 1/2 hour until one hour after the selected end time
    loop do
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
