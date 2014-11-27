class User < ActiveRecord::Base
  include Roles::Authorization
  devise :omniauthable,:omniauth_providers => [:nyulibraries]
  has_many :reservations, :dependent => :destroy

  attr_accessible :email, :firstname, :lastname, :username, :admin_roles, :institution_code, :aleph_id,
                  :patron_status, :college, :dept_code, :department, :major_code, :major

  scope :non_admin, where("admin_roles_mask = 0")
  scope :admin, where("admin_roles_mask > 0")
  scope :inactive, where("last_request_at < ?", 1.year.ago)

  acts_as_indexed :fields => [:firstname, :lastname, :username, :email]

  before_save :set_static_admins


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
