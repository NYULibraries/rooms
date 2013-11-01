class Room < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  # ElasticSearch index name
  index_name("#{Rails.env}_rooms")

  attr_accessible :title, :type_of_room, :description, :size_of_room, :image_link, :room_group_id
  
  has_many :reservations, :dependent => :destroy
  belongs_to :room_group

  validates_presence_of :title, :opens_at, :closes_at, :room_group_id
  before_create :set_sort_order
  before_save :set_sort_size_of_room, :if => :size_of_room?
  
  # Tire mapping to ElasticSearch index
  mapping do
    indexes :id, :index => :not_analyzed
    indexes :title, :index => :not_analyzed
    indexes :type_of_room, :index => :not_analyzed
    indexes :description
    indexes :size_of_room
    indexes :image_link, :index => :not_analyzed
    indexes :sort_order, :type => 'integer'
    indexes :sort_size_of_room, :type => 'integer'
    indexes :room_group, :as => "room_group.code", :index => :not_analyzed
    indexes :opens_at, :as => 'opens_at'
    indexes :closes_at, :as => 'closes_at'
  end 
  
  serialize :hours
  
private

  ##
  # Find maximum set_order attr and set current one to be after that
  def set_sort_order
    previous_max = Room.maximum("sort_order")
    write_attribute(:sort_order, previous_max +1)
  end
  
  ##
  # Set the sort_size_of_room attribute to an integer based on the string in size_of_room
  #
  # = Example
  #
  #   @room = Room.new(:size_of_room => "1-2 people")
  #   p @room.sort_size_of_room # 2
  def set_sort_size_of_room
    sort_size_of_room = size_of_room.split(" ").first.split("-").last.to_i
    write_attribute(:sort_size_of_room, sort_size_of_room)
  end

end
