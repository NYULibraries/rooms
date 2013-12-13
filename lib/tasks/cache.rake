namespace :cache do

    desc "Cache fields for reporting"
    task :reporting => :environment do
      # Force cache of all reporting fields so you can fetch them from cache without delay
      Rails.cache.write("room_types", Room.where("type_of_room IS NOT NULL and type_of_room != ''").uniq.pluck(:type_of_room), :expires_in => 30.days)
      Rails.cache.write("user_college_names", User.where("user_attributes LIKE '%college_name%'").uniq.pluck(:user_attributes), :expires_in => 30.days)
      Rails.cache.write("user_college_codes", User.where("user_attributes LIKE '%college_code%'").uniq.pluck(:user_attributes), :expires_in => 30.days)
      Rails.cache.write("user_dept_names", User.where("user_attributes LIKE '%dept_name%'").uniq.pluck(:user_attributes), :expires_in => 30.days)
      Rails.cache.write("user_majors", User.where("user_attributes LIKE '%major%'").uniq.pluck(:user_attributes), :expires_in => 30.days)
      Rails.cache.write("user_bor_statuses", User.where("user_attributes LIKE '%bor_status%'").uniq.pluck(:user_attributes), :expires_in => 30.days)
    end
    
    desc "Clear memcache"
    task :clear => :environment do
      ActionController::Base.cache_store.clear
    end
    
end