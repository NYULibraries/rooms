class AddFieldsToReservation < ActiveRecord::Migration
  def up
    add_column :reservations, :created_at_timezone, :string, :null => true
    add_column :reservations, :deleted_at_timezone, :string, :null => true
    add_column :reservations, :deleted_at, :timestamp, :null => true
  end
  def down
    remove_column :reservations, :created_at_timezone
    remove_column :reservations, :deleted_at_timezone
    remove_column :reservations, :deleted_at
  end
end
