class ChangeStatusColumnNameToPatronStatusInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :status, :patron_status
  end
end
