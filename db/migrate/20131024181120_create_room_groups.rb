class CreateRoomGroups < ActiveRecord::Migration
  def change
    create_table :room_groups do |t|
      t.string :title
      t.integer :admin_roles_mask

      t.timestamps
    end
  end
end
