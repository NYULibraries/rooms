class AddMajorCodeAttributeToUser < ActiveRecord::Migration
  def change
    add_column :users, :major_code, :string
  end
end
