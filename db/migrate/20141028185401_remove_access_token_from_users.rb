class RemoveAccessTokenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :access_token
  end

  def down
    add_column :users, :access_token, :string
  end
end
