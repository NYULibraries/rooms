class PopulateAlephIdFromUserAttributes < ActiveRecord::Migration
  def up
    say_with_time "Migrating Aleph ID." do
      User.all.each do |user|
        user.update_attribute :aleph_id, YAML.load(user.user_attributes)[:nyuidn]
      end
    end
  end

  def down
  end
end
