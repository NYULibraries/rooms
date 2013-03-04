class Reservation < ActiveRecord::Base
  attr_accessible :room_id, :user_id, :start_dt, :end_dt, :cc, :title, :is_block, :deleted, :deleted_by
  validates_presence_of :user_id, :room_id, :start_dt, :end_dt
  validate :doesnt_overlap, :if => Proc.new { |room_id| room_id? }, :unless => Proc.new { |is_block| is_block? }, :on => :create
  validate :collaborative_requires_ccs, :if => Proc.new { |room_id| room_id? and room.type_of_room.eql? "Collaborative" }, :unless => Proc.new { |is_block| is_block? }
  validate :dates_are_valid?
  validate :end_comes_after_start
  
  serialize :config_option, Hash
  serialize :deleted_by, Hash
    
  scope :active_with_blocks, :conditions => { :deleted => false }, :order => "start_dt ASC"
  scope :active_non_blocks, :conditions => { :deleted => false, :is_block => false }, :order => "start_dt ASC"
  scope :blocks, :conditions => { :is_block => true }, :order => "start_dt ASC"
  scope :deleted, :conditions => { :is_block => false, :deleted => true }, :order => "start_dt ASC"
  scope :current, lambda { where("end_dt > ?", Time.now.strftime("%Y-%m-%d %H:%M")) }
  scope :past, lambda { where("end_dt <= ?", Time.now.strftime("%Y-%m-%d %H:%M")) }
  scope :one_week, lambda { where("start_dt > ?", (Time.now - 1.week).strftime("%Y-%m-%d %H:%M")) }
  scope :one_month, lambda { where("start_dt > ?", (Time.now - 1.week).strftime("%Y-%m-%d %H:%M")) }

  belongs_to :room
  belongs_to :user
  
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
  
private

  def dates_are_valid?
    unless !start_dt.blank? and !end_dt.blank? and DateTime.parse(start_dt.to_s) and DateTime.parse(end_dt.to_s)
      errors.add(:base, "Please select a valid date and time in the format YYYY-MM-DD HH:MM for start and end fields. Note that minutes must be either 00 or 30.")
    end
  end

  def doesnt_overlap
    unless Reservation.active_with_blocks.where("room_id = ? AND ((start_dt >= ? AND  start_dt < ?) OR (end_dt > ? AND end_dt <= ?) OR (start_dt <= ? AND end_dt >= ?))", room.id, start_dt, start_dt, end_dt, end_dt, start_dt, end_dt).empty?
      errors.add(:base, "Sorry, your selected reservation slot was just taken. Please check the availability again.")
    end
  end
  
  def collaborative_requires_ccs
    if cc?
      if !is_valid_email? cc
        errors.add(:base, "One or more of the e-mails you entered is invalid.")
      elsif !current_user_is_only_email? cc
        errors.add(:base, "For collaborative rooms, please add at least one other e-mail besides your own.")
      end
    else
      errors.add(:base, "For collaborative rooms, please add at least one other valid e-mail from your group.")
    end
  end
  
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
    cc_emails_arr = cc_emails.split(",")
    if cc_emails_arr.size > 1
      cc_emails_arr.each do |email|
        br = current_user_is_only_email? email.strip
        return true if br
      end
    else
      return false if cc_emails_arr.first.downcase.eql? user.email.downcase
      return true unless cc_emails_arr.first.downcase.eql? user.email.downcase
    end
    return false
  end
  
end
