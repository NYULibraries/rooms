class DestroyUploadTable < ActiveRecord::Migration
  def up
    drop_table :uploads
  end

  def down

  end
end
