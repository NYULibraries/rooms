class User < ActiveRecord::Base
  include Roles::Authorization
  has_many :reservations, :dependent => :destroy

  scope :non_admin, -> { where("admin_roles_mask = 0") }
  scope :admin, -> { where("admin_roles_mask > 0") }
  scope :inactive, -> { where("last_request_at < ?", 1.year.ago)}

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
    if Figs.env.rooms_default_admins.include? username
      self.admin_roles = ["superuser", self.admin_roles].flatten.uniq
    end
  end

end
