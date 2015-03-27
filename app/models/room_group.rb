class RoomGroup < ActiveRecord::Base
  include Roles::Authorization
  validates_presence_of :title, :code, :admin_roles_mask
  has_many :rooms, :dependent => :nullify

  def code_sym
    self.code.to_sym
  end
end
