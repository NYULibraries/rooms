class AddCollaborativeToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :collaborative, :boolean
  end
end
