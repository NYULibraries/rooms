module ReportsHelper

  def room_type_options
    @room_types ||= Rails.cache.read "room_types" || []
  end

  def college_name_options
    @college_name_options ||= options(:college)
  end

  def college_code_options
    @college_code_options ||= options(:college_code)
  end

  def dept_options
    @dept_options ||= options(:department)
  end

  def major_options
    @major_options ||= options(:major)
  end

  def user_status_options
    @user_status_options ||= options(:patron_status)
  end

  def options(options_name)
    options = Rails.cache.read("user_#{options_name.to_s.pluralize}") || []
  end

end
