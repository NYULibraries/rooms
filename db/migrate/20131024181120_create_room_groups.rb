class CreateRoomGroups < ActiveRecord::Migration
  def change
    #drop_table :room_groups
    create_table :room_groups do |t|
      t.string :title
      t.integer :admin_roles_mask

      t.timestamps
    end
  end
end
