class RenameRolesMaskToAdminRolesMaskOnUsers < ActiveRecord::Migration
  def up
    rename_column :users, :roles_mask, :admin_roles_mask
  end

  def down
    rename_column :users, :admin_roles_mask, :roles_mask
  end
end
