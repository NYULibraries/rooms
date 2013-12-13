module ReportsHelper
  
  def room_type_options
    @room_types ||= Rails.cache.fetch "room_types", :expires_in => 30.days do
      Room.where("type_of_room IS NOT NULL and type_of_room != ''").uniq.pluck(:type_of_room)
    end
  end

  def college_name_options
    colleges = []
    @user_college_names ||= Rails.cache.fetch "user_college_names", :expires_in => 30.days do
      User.where("user_attributes LIKE '%college_name%'").uniq.pluck(:user_attributes)
    end
    @user_college_names.each do |p|
      colleges.push(p[:college_name]) unless colleges.include? p[:college_name] or p[:college_name].blank?
    end
    colleges
  end

  def college_code_options
    college_codes = []
    @user_college_codes ||= Rails.cache.fetch "user_college_codes", :expires_in => 30.days do
      User.where("user_attributes LIKE '%college_code%'").uniq.pluck(:user_attributes)
    end
    @user_college_codes.each do |p|
      college_codes.push(p[:college_code]) unless college_codes.include? p[:college_code] or p[:college_code].blank?
    end
    college_codes
  end

  def dept_options
    depts = []
    @user_dept_names ||= Rails.cache.fetch "user_dept_names", :expires_in => 30.days do
      User.where("user_attributes LIKE '%dept_name%'").uniq.pluck(:user_attributes)
    end
    @user_dept_names.each do |p|
      depts.push(p[:dept_name]) unless depts.include? p[:dept_name] or p[:dept_name].blank?
    end
    depts
  end

  def major_options
    majors = []
    @user_majors ||= Rails.cache.fetch "user_majors", :expires_in => 30.days do
      User.where("user_attributes LIKE '%major%'").uniq.pluck(:user_attributes)
    end
    @user_majors.each do |p|
      majors.push(p[:major]) unless majors.include? p[:major] or p[:major].blank?
    end
    majors
  end

  def user_status_options
    user_statuses = []
    @user_bor_statuses ||= Rails.cache.fetch "user_bor_statuses", :expires_in => 30.days do
      User.where("user_attributes LIKE '%bor_status%'").uniq.pluck(:user_attributes)
    end
    @user_bor_statuses.each do |p|
      user_statuses.push(p[:bor_status]) unless user_statuses.include? p[:bor_status] or p[:bor_status].blank?
    end
    user_statuses
  end
  
end