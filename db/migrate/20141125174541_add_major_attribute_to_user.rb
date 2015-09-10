class AddMajorAttributeToUser < ActiveRecord::Migration
  def change
    add_column :users, :major, :string
  end
end
