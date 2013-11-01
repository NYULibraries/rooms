class AddHoursStartAndHoursEndToRoom < ActiveRecord::Migration
  def up
    add_column :rooms, :hours_start, :string
    add_column :rooms, :hours_end, :string
  end
  
  def down
    remove_column :rooms, :hours_start
    remove_column :rooms, :hours_end
  end
end
