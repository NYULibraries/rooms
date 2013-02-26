class RenameStartAndEndInReservations < ActiveRecord::Migration
  def up
    rename_column :reservations, :start, :start_dt
    rename_column :reservations, :end, :end_dt
  end

  def down
    rename_column :reservations, :start_dt, :start
    rename_column :reservations, :end_dt, :end
  end
end
