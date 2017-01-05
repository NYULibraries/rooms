class RoomGroup < ActiveRecord::Base
  include Roles::Authorization
  validates_presence_of :title, :code, :admin_roles_mask
  has_many :rooms, :dependent => :nullify


end
