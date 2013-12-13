class AddRoomGroupIdToRooms < ActiveRecord::Migration
  def up
    add_column :rooms, :room_group_id, :integer
  end
  def down
    remove_column :rooms, :room_group_id
  end
end
