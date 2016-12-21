# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def prettify_time(t)
    t_ampm = if t.hour >= 12 then "pm" else "am" end
    t_hour = if t.hour == 0 then 12 elsif t.hour > 12 then ('%02d' % (t.hour - 12)) else ('%02d' % t.hour) end
    t_min = '%02d' % t.min
    t_time =  "<span class=\"hidden-xs\">#{t_hour.to_s}:#{t_min.to_s} #{t_ampm}</span><span class=\"visible-xs\">#{t_hour.to_s}:#{t_min.to_s}</span>"
    return t_time.html_safe
  end

  def prettify_date(d)
    d.strftime('%a. %b %d, %Y %I:%M %p') unless d.blank?
  end

  def prettify_simple_date(d)
    d.strftime('%m/%d/%Y').html_safe
  end

  def prettify_dayofweek(d)
    d.strftime('%a')
  end

  def simple_date_header(d)
    d.strftime('%A, %B %e, %Y')
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
    if Time.zone.now.strftime("%I").to_i == 11 and Time.zone.now.strftime("%M").to_i >= 30
      return (Time.zone.now.strftime("%p").downcase == "am") ? "pm" : "am"
    else
      return Time.zone.now.strftime("%p").downcase
    end
  end

  # Generate link to sorting action
  def sortable(column, title = nil, url_options = {}, remote = true)
    title ||= column.titleize
    css_class = column == sort_column.to_sym ? "current #{sort_direction}" : nil
    direction = column == sort_column.to_sym && sort_direction == "asc" ? "desc" : "asc"
    direction_icon = (direction.eql? "desc") ? :sort_desc : :sort_asc
    search = params[:search]
    title << icon_tag(direction_icon) if column == sort_column.to_sym
    title << icon_tag(:sortable) unless column == sort_column.to_sym
    html = link_to title.html_safe, params.merge(:sort => column, :direction => direction, :id => "").merge(url_options), {:data => {:remote => remote}, :class => css_class}.delete_if{ |key,value| key == :data && !remote }
    return html
  end

  def get_formatted_text(t, css = nil)
    simple_format(get_sanitized_detail(t), :class => css)
  end

  def get_sanitized_detail(t)
    sanitize(t, :tags => %w(b strong i em br p a ul li), :attributes => %w(target href class))
  end

  # Set a class to highlight item if this ID is selected in query string parameters
  def highlight(reservation)
    (!params[:highlight].blank? and params[:highlight].include? reservation.id.to_s) ? 'warning' : ''
  end

end
