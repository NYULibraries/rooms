class DestroyDbFileTable < ActiveRecord::Migration
  def up
    drop_table :db_files
  end

  def down
  end
end
