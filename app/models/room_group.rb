class RoomGroup < ActiveRecord::Base
  include Roles::Authorization
  validates_presence_of :title, :code, :admin_roles_mask
  attr_accessible :title, :code, :admin_roles
  has_many :rooms, :dependent => :nullify
  
  def code_sym
    self.code.to_sym
  end
end
