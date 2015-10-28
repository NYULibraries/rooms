class AddCollegeCodeToUsers < ActiveRecord::Migration
  def up
    add_column :users, :college_code, :string
  end

  def down
    remove_column :users, :college_code
  end
end
