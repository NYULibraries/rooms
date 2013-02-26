namespace :cleanup do

    desc "Cleanup users who have been inactive for over a year"
    task :expired_users => :environment do
      @log = Logger.new("log/destroy_inactive_users.log")
      destroyed = User.destroy_all("last_login_at < '#{1.year.ago.to_datetime}'")
      @log.error "[#{Time.now.to_formatted_s(:db)}] #{destroyed.count} users destroyed"
    end
    
    desc "Cleanup reservations which were deleted over a year ago"
    task :deleted_reservations => :environment do
      @log = Logger.new("log/destroy_deleted_reservations.log")
      destroyed = Reservation.destroy_all("is_block = 0 AND deleted = 1 AND updated_at < '#{1.year.ago.to_datetime}'")
      @log.error "[#{Time.now.to_formatted_s(:db)}] #{destroyed.count} reservations destroyed"
    end
    
end