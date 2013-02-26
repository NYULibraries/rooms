class AddSortSizeOfRoomToRooms < ActiveRecord::Migration
  def up
    add_column :rooms, :sort_size_of_room, :integer, :default => 0
  end

  def down
    remove_column :rooms, :sort_size_of_room
  end
end
