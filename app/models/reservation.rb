class Reservation < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  index_name("#{Rails.env}_reservations")
  
  attr_accessible :room_id, :user_id, :start_dt, :end_dt, :cc, :title, :is_block, :deleted, :deleted_by
  
  # Validations for Reservation
  validates_presence_of :user_id, :room_id, :start_dt, :end_dt
  # Allow overlap if reservation is an admin-created block because all other reservations will be deleted for the block
  validate :doesnt_overlap, :if => Proc.new { |room_id| room_id? }, :unless => Proc.new { |is_block| is_block? }, :on => :create
  validate :validate_cc
  # Require CCs if collaborative room
  validate :collaborative_requires_ccs
  validate :dates_are_valid?
  validate :end_comes_after_start
  after_initialize :dates_are_valid? # Reservation.new(:start_dt => start_dt, :end_dt => end_dt)
  
  # Non-database attributes
  attr_accessor :created_at_day, :created_at_timezone, :deleted_at_timezone
  # Require initialization
  #after_initialize :populate_created_at_day
  after_initialize :populate_timezones
  
  serialize :deleted_by, Hash
  
  # Scopes
  scope :active_with_blocks, :conditions => { :deleted => false }, :order => "start_dt ASC"
  scope :active_non_blocks, :conditions => { :deleted => false, :is_block => false }, :order => "start_dt ASC"
  scope :blocks, :conditions => { :is_block => true }, :order => "start_dt ASC"
  scope :deleted, :conditions => { :is_block => false, :deleted => true }, :order => "start_dt ASC"
  scope :current, lambda { where("end_dt > ?", Time.zone.now.strftime("%Y-%m-%d %H:%M")) }
  scope :past, lambda { where("end_dt <= ?", Time.zone.now.strftime("%Y-%m-%d %H:%M")) }
  scope :one_week, lambda { where("start_dt > ?", (Time.zone.now - 1.week).strftime("%Y-%m-%d %H:%M")) }
  scope :one_month, lambda { where("start_dt > ?", (Time.zone.now - 1.month).strftime("%Y-%m-%d %H:%M")) }

  belongs_to :room
  belongs_to :user
  
  # Tire ElasticSearch mapping
  unless Rails.env == "test"
    mapping do
      # Map to database values
      indexes :id,           :index    => :not_analyzed
      indexes :room_id
      indexes :user_id
      indexes :start_dt, :as => 'start_dt.strftime("%Y-%m-%d %H:%M:%S").to_datetime', :index => :not_analyzed, :type => 'date', :format => "yyyy-MM-dd'T'HH:mm:ssZ"
      indexes :end_dt, :as => 'end_dt.strftime("%Y-%m-%d %H:%M:%S").to_datetime', :index => :not_analyzed, :type => 'date', :format => "yyyy-MM-dd'T'HH:mm:ssZ"
      indexes :is_block, :type => 'boolean'
      indexes :deleted, :type => 'boolean'
      # Mappings for non-database values
      indexes :created_at_day, :as => 'created_at.in_time_zone.strftime("%Y-%m-%d")', :type => 'date'
      indexes :start_day, :index => :not_analyzed, :as => 'start_dt.strftime("%Y-%m-%d")', :type => 'date'
      indexes :created_at_timezone, :as => 'created_at_timezone'
      indexes :deleted_at_timezone, :as => 'deleted_at_timezone'
    end
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

  # Created_at_day is not stored in database and requires preprocessing, 
  # so after object is found initialize Rails attr from ElasticSearch
  #def populate_created_at_day
  #  if new_record?
  #    self.created_at_day = Time.zone.now.strftime("%Y-%m-%d")
  #  else
  #    @populate_created_at_day ||= Reservation.search "id:#{id}"
  #    unless @populate_created_at_day.results.empty?
  #      self.created_at_day = @populate_created_at_day.results.first.created_at_day
  #    end
  #  end
  #end
  
  # Timezone attrs are not stored in database, so when the object is found 
  # initialize the Rails attr from the ElasticSearch results
  def populate_timezones
    if new_record?
      self.created_at_timezone = Time.zone.name
    else
      @populate_timezones ||= Reservation.search "id:#{id}"
      unless @populate_timezones.results.empty?
        self.created_at_timezone = @populate_timezones.results.first.created_at_timezone
        self.deleted_at_timezone = Time.zone.name
      end
    end
  end

  # Perform a check to find if the user has already created a reservation today
  def rr_made_today?
    return false if user.user_attributes[:room_reserve_admin]
    # Find today's date as comparable object
    today = Time.zone.now.strftime('%Y-%m-%d')
    # find if this user has already made a reservation today...
    current_user = user
    @rr_made_today ||= Reservation.search do 
      query do
        string "created_at_day:#{today}" 
        filtered do
          filter :term, :deleted => false
          filter :term, :is_block => false
          filter :term, :user_id => current_user.id
        end
      end
    end 
    return !@rr_made_today.results.blank?
  end

  # Perform a check to find if the user already has a reservation for this day
  def rr_for_same_day?
    return false if user.user_attributes[:room_reserve_admin]
    # Find date of reservation as comparable date
    reservation_day = start_dt.strftime('%Y-%m-%d')
    # or if they made a reservation for the selected day already
    current_user = user
    @rr_for_same_day ||= Reservation.search do 
      query do
        string "start_day:#{reservation_day}"
        filtered do
          filter :term, :deleted => false
          filter :term, :is_block => false
          filter :term, :user_id => current_user.id
        end
      end
    end
    return !@rr_for_same_day.results.blank?
  end
  
private

  # Start date and end date must be present and valid before inserting into database
  def dates_are_valid?
    if !start_dt.blank? and !end_dt.blank? and (!DateTime.parse(start_dt.to_s) or !DateTime.parse(end_dt.to_s))
      errors.add(:base, "Please select a valid date and time in the format YYYY-MM-DD HH:MM for start and end fields. Note that minutes must be either 00 or 30.")
    end
  end

  # Do a ElasticSearch search to make sure there isn't already an overlapping reservation in the index
  # Since user's cannot generally reserve a timeslot if another reservation overlaps, this will only occur
  # when more than one user is simultaneously attempting to reserve the same room/time
  def doesnt_overlap
    if !start_dt.blank? and !end_dt.blank?
      room_id = room.id
      start_dt = self.start_dt.to_datetime.change(:offset => "+0000")
      end_dt = self.end_dt.to_datetime.change(:offset => "+0000")
      status_search = Reservation.search do 
        query { all }
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
        size 1
      end
      status = status_search.results.first
      unless status.blank?
        errors.add(:base, "Sorry, your selected reservation slot was just taken. Please check the availability again.")
      end
    end
  end
  
  # If CC/s are present, make sure it/they're valid email/s
  def validate_cc
    if cc? and !is_valid_email? cc
      errors.add(:base, "One or more of the e-mails you entered is invalid.")
    end
  end
  
  # If collaborative room, valid CCs are required, and it can't just be the user's email
  def collaborative_requires_ccs
    if room_id? and room.type_of_room.strip.eql? "Collaborative" and !is_block?
      if cc? 
        if current_user_is_only_email? cc
          errors.add(:base, "For collaborative rooms, please add at least one other e-mail besides your own.")
        end
      else
        errors.add(:base, "For collaborative rooms, please add at least one other valid e-mail from your group.")
      end
    end
  end
  
  # Verify end date is after start date
  def end_comes_after_start
    errors.add(:base, "Please select a valid end date that is after your selected start date.") if !start_dt.blank? and !end_dt.blank? and start_dt > end_dt
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
