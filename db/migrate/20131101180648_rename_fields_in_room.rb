class RenameFieldsInRoom < ActiveRecord::Migration
  def up
    rename_column :rooms, :hours_start, :opens_at
    rename_column :rooms, :hours_end, :closes_at
  end

  def down
    rename_column :rooms, :opens_at, :hours_start
    rename_column :rooms, :closes_at, :hours_end
  end
end
