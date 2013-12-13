class AddGroupCodeToRoomGroups < ActiveRecord::Migration
  def up
    add_column :room_groups, :code, :string
  end
  
  def down
    remove_column :room_groups, :code
  end
end
