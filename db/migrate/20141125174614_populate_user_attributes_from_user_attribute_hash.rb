class PopulateUserAttributesFromUserAttributeHash < ActiveRecord::Migration
  def up
    say_with_time "Migrating user attributes from user_attributes hash." do
      User.class_eval { serialize :user_attributes }
      User.all.each do |user|
        if !user.user_attributes.nil?
          user.update_attribute :institution_code,  user.user_attributes[:institution] rescue ''
          user.update_attribute :college,           user.user_attributes[:college_name] rescue ''
          user.update_attribute :dept_code,         user.user_attributes[:dept_code] rescue ''
          user.update_attribute :department,        user.user_attributes[:dept_name] rescue ''
          user.update_attribute :major_code,        user.user_attributes[:major_code] rescue ''
          user.update_attribute :major,             user.user_attributes[:major] rescue ''
          user.update_attribute :status,            user.user_attributes[:patron_status] rescue ''
        end
      end
    end
  end

  def down
  end
end
