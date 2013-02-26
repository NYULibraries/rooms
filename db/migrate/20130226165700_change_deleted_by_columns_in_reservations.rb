class ChangeDeletedByColumnsInReservations < ActiveRecord::Migration
  def up
    rename_column :reservations, :deleted, :deleted_by
    add_column :reservations, :deleted, :boolean, :default => 0, :null => true
  end

  def down
    remove_column :reservations, :deleted
    rename_column :reservations, :deleted_by, :deleted
  end
end
