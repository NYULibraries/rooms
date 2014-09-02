class Reservation < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  # elasticsearch index name
  index_name("#{Rails.env}_reservations")

  belongs_to :room
  belongs_to :user

  attr_accessible :room_id, :user_id, :start_dt, :end_dt, :cc, :title, :is_block, :deleted, :deleted_by, :deleted_at

  validates_presence_of :user_id, :room_id, :start_dt, :end_dt

  validate :reservation_available, :if => :room_id?, :unless => :is_block?, :on => :create
  validate :reservations_exist_in_block, :if => :is_block?, :unless => Proc.new {|start_dt| start_dt.blank? }, :unless => Proc.new {|end_dt| end_dt.blank? }, :on => :create
  validate :validate_cc, :unless => :is_block?
  validate :collaborative_requires_ccs, :unless => :is_block?

  # Non-database attributes
  attr_accessor :created_at_day

  before_save :populate_timezones
  before_save :populate_deleted_at

  serialize :deleted_by, Hash

  # Scopes
  # Active non blocks still used in reporting controller
  scope :blocks, :conditions => { :is_block => true }, :order => "start_dt ASC"
  scope :active, :conditions => { :deleted => false }, :order => "start_dt ASC"
  scope :no_blocks, :conditions => { :is_block => false }, :order => "start_dt ASC"
  scope :deleted, :conditions => { :is_block => false, :deleted => true }, :order => "start_dt ASC"
  scope :current, lambda { where("end_dt > ?", Time.zone.now.strftime("%Y-%m-%d %H:%M")) }
  scope :past, lambda { where("end_dt <= ?", Time.zone.now.strftime("%Y-%m-%d %H:%M")) }
  scope :one_week, lambda { where("start_dt > ?", (Time.zone.now - 1.week).strftime("%Y-%m-%d %H:%M")) }
  scope :one_month, lambda { where("start_dt > ?", (Time.zone.now - 1.month).strftime("%Y-%m-%d %H:%M")) }

  # Tire ElasticSearch mapping
  mapping do
    # Map to database values
    indexes :id, :index => :not_analyzed
    indexes :room_id, :index => :not_analyzed
    indexes :user_id, :index => :not_analyzed
    indexes :title, :index => :not_analyzed
    indexes :start_dt, :as => 'start_dt.strftime("%Y-%m-%d %H:%M:%S").to_datetime', :index => :not_analyzed, :type => 'date', :format => "yyyy-MM-dd'T'HH:mm:ssZ"
    indexes :end_dt, :as => 'end_dt.strftime("%Y-%m-%d %H:%M:%S").to_datetime', :index => :not_analyzed, :type => 'date', :format => "yyyy-MM-dd'T'HH:mm:ssZ"
    indexes :is_block, :type => 'boolean'
    indexes :deleted, :type => 'boolean'
    # Mappings for non-database values
    indexes :created_at_day, :as => 'created_at.in_time_zone.strftime("%Y-%m-%d")', :index => :not_analyzed, :type => 'date'
    indexes :start_day, :as => 'start_dt.strftime("%Y-%m-%d")', :index => :not_analyzed, :type => 'date'
  end

  # CSV mapping
  comma do
    start_dt 'Start' do |start_dt| start_dt.strftime("%Y-%m-%d %H:%m") end
    end_dt 'End' do |end_dt| end_dt.strftime("%Y-%m-%d %H:%m") end
    user 'Name' do |user| "#{user.lastname}, #{user.firstname}" end
    user 'Username' do |user| user.username end
    user 'College Name' do |user| user.user_attributes[:college_name] end
    user 'College Code' do |user| user.user_attributes[:college_code] end
    user 'Department Affiliation' do |user| (user.user_attributes[:dept_name]) ? user.user_attributes[:dept_code] : user.user_attributes[:dept_name] end
    user 'Major' do |user| (user.user_attributes[:major]) ? user.user_attributes[:major_code] : user.user_attributes[:major] end
    user 'Patron Status' do |user| user.user_attributes[:bor_status] end
    room 'Room Name' do |room| room.title end
    room 'Room Type' do |room| room.type_of_room end
  end

  ##
  # Finds existing reservations for this timeslot
  #
  # = Example
  #
  #   @reservation.existing_reservations # Returns array of tire results
  def existing_reservations
    if !self.start_dt.blank? && !self.end_dt.blank? && !self.room.blank?
      start_dt = self.start_dt.to_datetime.change(:offset => "+0000")
      end_dt = self.end_dt.to_datetime.change(:offset => "+0000")
      is_block = self.is_block?
      room_id = self.room.id
      results_size = (self.is_block?) ? 1000 : 1

      existing_reservations = Reservation.tire.search do
        query do
          filtered do
            filter :term, :is_block => false if is_block
            filter :range, :end_dt => { :gte => Time.zone.now.to_datetime.change(:offset => "+0000") } if is_block
            filter :term, :room_id => room_id
            filter :term, :deleted => false
            filter :or,
              { :and => [
                  { :range => { :start_dt => { :gte => start_dt } } },
                  { :range => { :start_dt => { :lt => end_dt } } }
              ]},
              { :and => [
                  { :range => { :end_dt => { :gt => start_dt } } },
                  { :range => { :end_dt => { :lte => end_dt } } }
              ]},
              { :and => [
                  { :range => { :start_dt => { :lte => start_dt } } },
                  { :range => { :end_dt => { :gte => end_dt } } }
              ]}
          end
        end
        size results_size
      end

      return existing_reservations.results
    end
    []
  end

  ##
  # Boolean returns if any reservations were found for timeslot
  #
  # = Example
  #
  #   @reservation.existing_reservations? # Returns bool
  def existing_reservations?
    !existing_reservations.empty?
  end

  ##
  # Perform a check to find if the user has already created a reservation today
  def made_today?
    reservation_on_day?("created_at_day", Time.zone.now.strftime('%Y-%m-%d'))
  end

  ##
  # Perform a check to find if the user already has a reservation for this day
  def on_same_day?(reservation)
    (reservation.blank? || reservation.start_dt.blank?) ? false : reservation_on_day?("start_day", reservation.start_dt.strftime('%Y-%m-%d'))
  end

private

  ##
  # Return count if reservation is found on a specifc day field
  def reservation_on_day?(on_day_field, on_day)
    reservation_day = start_dt.strftime('%Y-%m-%d')
    user_id = user.id
    on_day_field = on_day_field
    on_day = on_day
    reservation_on_day ||= Reservation.tire.search :search_type => "count" do
      query do
        filtered do
          filter :term, :deleted => false
          filter :term, :is_block => false
          filter :term, :user_id => user_id
          query do
            string "#{on_day_field}:#{on_day}"
          end
        end
      end
    end
    return reservation_on_day.total > 0
  end

  ##
  # Timezone attrs are not stored in database, so on initialize set the timezones to the found values in elasticsearch
  def populate_timezones
    if new_record?
      self.created_at_timezone ||= Time.zone.name
    else
      if self.deleted?
        self.deleted_at_timezone ||= Time.zone.name
      end
    end
  end

  def populate_deleted_at
    if self.deleted?
      self.deleted_at ||= Time.zone.now
    end
  end

  # Print an error message if another reservation exists in the selected timeslot when user is creating a reservation
  def reservation_available
    if timeslot_contains_reservations?
      errors.add(:base, I18n.t('reservation.reservation_available'))
    end
  end

  # Print an error message if another reservation exists in the selected timeslot when admin is creating a block
  def reservations_exist_in_block
    if timeslot_contains_reservations?
      errors.add(:base, I18n.t('reservation.reservations_exist_in_block'))
    end
  end

  # Boolean returns true if the selected timeslot (i.e. start_dt through end_dt) contains other reservations
  def timeslot_contains_reservations?
    return start_dt.blank? || end_dt.blank? || existing_reservations?
  end

  # If CC/s are present, make sure it/they're valid email/s
  def validate_cc
    if cc? and !is_valid_email? cc
      errors.add(:base, I18n.t('reservation.validate_cc'))
    end
  end

  # If collaborative room, valid CCs are required, and it can't just be the user's email
  def collaborative_requires_ccs
    if room_id? and room.collaborative?
      if cc?
        if current_user_is_only_email? cc
          errors.add(:base, I18n.t('reservation.current_user_is_only_email'))
        end
      else
        errors.add(:base, I18n.t('reservation.collaborative_requires_ccs'))
      end
    end
  end

  # Check that the email submitted is a valid email address
  def is_valid_email?(emails)
    emails_arr = emails.split(",")
    if emails_arr.is_a?(Array) and emails_arr.size > 1
      emails_arr.each do |email|
        br = is_valid_email? email.strip
        return false if !br
      end
    else
      return false unless emails_arr.first.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
    end
    return true
  end

  # Perform a check to make sure the CC email submitted is not only their own email address
  def current_user_is_only_email?(cc_emails)
    cc_emails_arr = cc_emails.split(",").uniq
    return (cc_emails_arr.size == 1 and cc_emails_arr.include? user.email)
  end

end
