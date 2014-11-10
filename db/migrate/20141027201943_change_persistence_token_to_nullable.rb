class ChangePersistenceTokenToNullable < ActiveRecord::Migration
  def up
    change_column :users, :persistence_token, :string, :null => true
  end

  def down
    change_column :users, :persistence_token, :string, :null => false
  end
end
