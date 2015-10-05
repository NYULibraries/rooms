class AddDefaultValueToProvider < ActiveRecord::Migration
  def up
    say_with_time "Migrating provider from NULL to blank" do
      User.all.each do |user|
        user.provider = '' if user.provider.nil?
        user.save(:validate => false)
      end
    end
    change_column :users, :provider, :string, default: "", null: false
  end
  def down
    change_column :users, :provider, :string, null: true
  end
end
