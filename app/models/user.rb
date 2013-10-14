class User < ActiveRecord::Base
  ROLES = %w[superuser ny_admin shanghai_admin]
  has_many :reservations, :dependent => :destroy
  
  attr_accessible :crypted_password, :current_login_at, :current_login_ip, :email, :firstname, :last_login_at, :last_login_ip, :last_request_at, :lastname, :login_count, :mobile_phone, :password_salt, :persistence_token, :refreshed_at, :session_id, :user_attributes, :username
  attr_accessible :roles
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
  
  # Bitwise roles field in database per
  # https://github.com/ryanb/cancan/wiki/Role-Based-Authorization#many-roles-per-user
  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
    end
  end
  
  def roles_list
    roles.join(", ").humanize.titleize
  end
  
  def is?(role)
    roles.include?(role.to_s)
  end

  
end