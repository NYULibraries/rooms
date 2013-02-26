class RenameColumns < ActiveRecord::Migration
  def up
    rename_column :rooms, :display_order, :sort_order
  end

  def down
    rename_column :rooms, :sort_order, :display_order
  end
end
