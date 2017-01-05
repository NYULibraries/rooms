require 'elasticsearch/model'

class Room < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # elasticsearch index name
  index_name { "#{Rails.env}_rooms" }

  has_many :reservations, :dependent => :destroy
  belongs_to :room_group

  validates_presence_of :title, :opens_at, :closes_at, :room_group_id
  before_create :set_sort_order
  before_save :set_sort_size_of_room, :if => :size_of_room?

  settings index: { number_of_shards: 1 } do
    mappings dynamic: "false" do
      indexes :id, type: "integer"
      indexes :title, type: "string"
      indexes :type_of_room, type: "string"
      indexes :description, type: "string"
      indexes :size_of_room, type: "string"
      indexes :image_link, type: "string"
      indexes :sort_order, type: "integer"
      indexes :sort_size_of_room, type: "integer"
      indexes :room_group, type: "string"
      indexes :opens_at, type: "string"
      indexes :closes_at, type: "string"
    end
  end

  def as_indexed_json(options={})
    {
      id: id,
      title: title,
      type_of_room: type_of_room,
      description: description,
      size_of_room: size_of_room,
      image_link: image_link,
      sort_order: sort_order,
      sort_size_of_room: sort_size_of_room,
      room_group: room_group.code,
      opens_at: opens_at,
      closes_at: closes_at
    }
  end

  serialize :hours

  # Convenience method for use in API
  def current_reservations
    self.reservations.current.active
  end

private

  ##
  # Find maximum set_order attr and set current one to be after that
  def set_sort_order
    previous_max = Room.maximum("sort_order") || 0
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
