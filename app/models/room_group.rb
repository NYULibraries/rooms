class RoomGroup < ActiveRecord::Base
  include Rooms::Authorization
  validates_presence_of :title, :code, :admin_roles_mask
  attr_accessible :title, :code, :admin_roles
  has_many :rooms, :dependent => :destroy
end
