class RenameTablePatronsToUsers < ActiveRecord::Migration
  def self.up
    #drop_table :users
    rename_table :patrons, :users
  end 
  def self.down
    rename_table :users, :patrons
  end
end
