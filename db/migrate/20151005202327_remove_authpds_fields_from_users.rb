class RemoveAuthpdsFieldsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :mobile_phone if column_exists? :users, :mobile_phone
    remove_column :users, :crypted_password if column_exists? :users, :crypted_password
    remove_column :users, :password_salt if column_exists? :users, :password_salt
    remove_column :users, :session_id if column_exists? :users, :session_id
    remove_column :users, :persistence_token if column_exists? :users, :persistence_token
    remove_column :users, :login_count if column_exists? :users, :login_count
    remove_column :users, :last_request_at if column_exists? :users, :last_request_at
    remove_column :users, :current_login_at if column_exists? :users, :current_login_at
    remove_column :users, :last_login_at if column_exists? :users, :last_login_at
    remove_column :users, :last_login_ip if column_exists? :users, :last_login_ip
    remove_column :users, :current_login_ip if column_exists? :users, :current_login_ip
  end

  def down
    add_column :users, :mobile_phone, :string unless column_exists? :users, :mobile_phone, :string
    add_column :users, :crypted_password, :string unless column_exists? :users, :crypted_password, :string
    add_column :users, :password_salt, :string unless column_exists? :users, :password_salt, :string
    add_column :users, :session_id, :string unless column_exists? :users, :session_id, :string
    add_column :users, :persistence_token, :string unless column_exists? :users, :persistence_token, :string
    add_column :users, :login_count, :integer unless column_exists? :users, :login_count, :integer
    add_column :users, :last_request_at, :string unless column_exists? :users, :last_request_at, :string
    add_column :users, :current_login_at, :string unless column_exists? :users, :current_login_at, :string
    add_column :users, :last_login_at, :string unless column_exists? :users, :last_login_at, :string
    add_column :users, :last_login_ip, :string unless column_exists? :users, :last_login_ip, :string
    add_column :users, :current_login_ip, :string unless column_exists? :users, :current_login_ip, :string
  end
end
