namespace :cache do

    desc "Cache fields for reporting"
    task :reporting => :environment do
      # Force cache of all reporting fields so you can fetch them from cache without delay
      Rails.cache.write "room_types", :expires_in => 30.days do
        Room.where("type_of_room IS NOT NULL and type_of_room != ''").uniq.pluck(:type_of_room)
      end
      user_fields = [:college_name,:college_code,:dept_name,:major,:bor_status]
      user_fields.each do |user_field|
        options = []
        user_attributes = User.where("user_attributes LIKE '%college_name%'").uniq.pluck(:user_attributes)
        user_attributes.each do |attrs|
          options.push(attrs[user_field]) unless options.include?(attrs[user_field]) || attrs[user_field].blank?
        end
        options = options.sort
        options.uniq!
        Rails.cache.write "user_#{user_field.to_s.pluralize}", options, expires_in: 30.days
      end
    end

    desc "Clear memcache"
    task :clear => :environment do
      ActionController::Base.cache_store.clear
    end

end
