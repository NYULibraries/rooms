class Room < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  index_name("#{Rails.env}_rooms")

  attr_accessible :title, :type_of_room, :description, :size_of_room, :image_link
  
  validates_presence_of :title
  
  has_many :reservations, :dependent => :destroy
  
  before_create :set_sort_order
  before_save :set_sort_size_of_room, :if => :size_of_room?
  
  serialize :hours 
  
  unless Rails.env == "test"
    mapping do
      indexes :id,           :index    => :not_analyzed
      indexes :title,        :index    => :not_analyzed
      indexes :type_of_room, :index    => :not_analyzed
      indexes :description
      indexes :image_link
      indexes :sort_order, :type => 'integer'
      indexes :size_of_room
      indexes :sort_size_of_room, :type => 'integer'
    end
  end
  
private

  def set_sort_order
    previous_max = Room.maximum("sort_order")
    write_attribute(:sort_order, previous_max +1)
  end
  
  def set_sort_size_of_room
    sort_size_of_room = size_of_room.split(" ").first.split("-").last.to_i
    write_attribute(:sort_size_of_room, sort_size_of_room)
  end

end
