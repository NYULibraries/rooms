class User < ActiveRecord::Base
  include Rooms::Authorization
  has_many :reservations, :dependent => :destroy
  
  attr_accessible :email, :firstname, :lastname, :user_attributes, :username, :admin_roles
  attr_accessible :crypted_password, :current_login_at, :current_login_ip, :last_login_at, :last_login_ip, :last_request_at, :login_count, :mobile_phone, :password_salt, :persistence_token, :refreshed_at, :session_id 
  
  scope :non_admin, where("admin_roles_mask = 0 OR roles_mask IS NULL")
  scope :admin, where("admin_roles_mask > 0")
  scope :inactive, where("last_request_at < ?", 1.year.ago)

  serialize :user_attributes
  
  acts_as_indexed :fields => [:firstname, :lastname, :username, :email]
  
  before_save :set_static_admins
  
  # Configure authlogic
  acts_as_authentic do |c|
    c.validations_scope = :username
    c.validate_password_field = false
    c.require_password_confirmation = false  
    c.disable_perishable_token_maintenance = true
  end
  
  ##
  # Create a CSV format with comma DSL
  #
  # = Example
  #
  # format.csv { render :csv }
  comma do
    username
    firstname
    lastname
    email
  end
  
private

  def set_static_admins
    if Settings.login.default_admins.include? username
      admin_roles = ["global", self.admin_roles].flatten.uniq
    end
  end
  
end