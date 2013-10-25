class Room < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  # ElasticSearch index name
  index_name("#{Rails.env}_rooms")
  #index_name("test_rooms")

  attr_accessible :title, :type_of_room, :description, :size_of_room, :image_link, :room_group_id
  
  has_many :reservations, :dependent => :destroy
  belongs_to :room_group

  validates_presence_of :title, :hours, :room_group_id
  before_create :set_sort_order
  before_save :set_sort_size_of_room, :if => :size_of_room?
  
  serialize :hours 
  
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
  end
  
  ##
  # Return Tire result from idnex where reservation falls within the given timeslot
  #
  # = Example
  #
  #   @room.find_reservation_by_timeslot(DateTime.now)
  def find_reservation_by_timeslot(timeslot)
    t_next = timeslot + 30.minutes #next iteration's time
    timeslot = timeslot
    room_id = self.id
    
    reservation ||= Reservation.tire.search do 
      filter :term, :room_id => room_id
      filter :term, :deleted => false
      filter :or, 
        { :and => [
            { :range => { :start_dt => { :gte => timeslot } } },
            { :range => { :end_dt => { :lte => t_next } } }
        ]},
        { :and => [
            { :range => { :start_dt => { :lte => timeslot } } },
            { :range => { :end_dt => { :gte => t_next } } }
        ]}
      size 1
    end
    return reservation.results.first
  end

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
