class AddDeptCodeAttributeToUser < ActiveRecord::Migration
  def change
    add_column :users, :dept_code, :string
  end
end
