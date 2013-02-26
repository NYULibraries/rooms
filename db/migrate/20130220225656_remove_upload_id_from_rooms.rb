class RemoveUploadIdFromRooms < ActiveRecord::Migration
  def up
    remove_column :rooms, :upload_id
  end

  def down
  end
end
