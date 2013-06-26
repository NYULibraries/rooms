class User < ActiveRecord::Base
  has_many :reservations, :dependent => :destroy
  
  attr_accessible :crypted_password, :current_login_at, :current_login_ip, :email, :firstname, :last_login_at, :last_login_ip, :last_request_at, :lastname, :login_count, :mobile_phone, :password_salt, :persistence_token, :refreshed_at, :session_id, :user_attributes, :username
  scope :non_admin, where("user_attributes NOT LIKE '%:room_reserve_admin: true%'")
  scope :admin, where("user_attributes LIKE '%:room_reserve_admin: true%'")
  scope :inactive, where("last_request_at < ?", 1.year.ago)

  serialize :user_attributes
  
  acts_as_authentic do |c|
    c.validations_scope = :username
    c.validate_password_field = false
    c.require_password_confirmation = false  
    c.disable_perishable_token_maintenance = true
  end

  def self.search(search)
    if search
      q = "%#{search}%"
      where('firstname LIKE ? || lastname LIKE ? || username LIKE ? || email LIKE ?', q, q, q, q)
    else
      scoped
    end
  end
  
  # Create a CSV format
  comma do
    username
    firstname
    lastname
    email
  end
end