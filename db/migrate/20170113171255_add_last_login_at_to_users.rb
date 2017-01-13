class AddLastLoginAtToUsers < ActiveRecord::Migration
  def up
    add_column :users, :last_login_at, :datetime
  end
  def down
    remove_column :users, :last_login_at
  end
end
