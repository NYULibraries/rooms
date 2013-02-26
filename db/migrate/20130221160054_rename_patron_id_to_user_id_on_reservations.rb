class RenamePatronIdToUserIdOnReservations < ActiveRecord::Migration
  def up
    rename_column :reservations, :patron_id, :user_id
  end

  def down
    rename_column :reservations, :user_id, :patron_id
  end
end
