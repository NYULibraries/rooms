class PopulateUserAttributesFromUserAttributeHash < ActiveRecord::Migration
  def up
    say_with_time "Migrating user attributes from user_attributes hash." do
      User.all.each do |user|
        user.update_attribute :institution_code,  user.user_attributes[:institution]
        user.update_attribute :college,           user.user_attributes[:college_name]
        user.update_attribute :dept_code,         user.user_attributes[:dept_code]
        user.update_attribute :department,        user.user_attributes[:dept_name]
        user.update_attribute :major_code,        user.user_attributes[:major_code]
        user.update_attribute :major,             user.user_attributes[:major]
        user.update_attribute :status,            user.user_attributes[:patron_status]
      end
    end
  end

  def down
  end
end
