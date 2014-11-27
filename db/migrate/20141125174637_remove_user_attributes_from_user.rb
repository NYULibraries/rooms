class RemoveUserAttributesFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :user_attributes
  end
end
