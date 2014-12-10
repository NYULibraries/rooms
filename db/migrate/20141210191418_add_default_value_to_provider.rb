class AddDefaultValueToProvider < ActiveRecord::Migration
  def change
    change_column :users, :provider, :string, :default => ""
  end
end
