module ReportsHelper
  
  def room_type_options
    @room_types ||= Rails.cache.fetch "room_types", :expires_in => 30.days do
      Room.where("type_of_room IS NOT NULL and type_of_room != ''").uniq.pluck(:type_of_room)
    end
  end

  def college_name_options
    @college_name_options ||= options(:college_name)
  end

  def college_code_options
    @college_code_options ||= options(:college_code)
  end

  def dept_options
    @dept_options ||= options(:dept_name)
  end

  def major_options
    @major_options ||= options(:major)
  end

  def user_status_options
    @user_status_options ||= options(:bor_status)
  end
  
  def options(options_name)
    options = []
    user_options = Rails.cache.fetch "user_#{options_name.to_s.pluralize}", :expires_in => 30.days do
      User.where("user_attributes LIKE '%#{options_name.to_s}%'").uniq.pluck(:user_attributes)
    end
    user_options.each do |p|
      options.push(p[options_name]) unless options.include? p[options_name] or p[options_name].blank?
    end
    options
  end
  
end