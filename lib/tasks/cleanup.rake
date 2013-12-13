namespace :cleanup do

    desc "Cleanup users who have been inactive for over a year"
    task :users => :environment do
      @log = Logger.new("log/destroy_inactive_users.log")
      destroyed = User.non_admin.inactive.destroy_all
      @log.error "[#{Time.now.to_formatted_s(:db)}] #{destroyed.count} users destroyed"
    end
    
    desc "Cleanup reservations from over a year ago"
    task :reservations => :environment do
      @log = Logger.new("log/destroy_deleted_reservations.log")
      destroyed = Reservation.destroy_all(["end_dt < ?", 1.year.ago])
      @log.error "[#{Time.now.to_formatted_s(:db)}] #{destroyed.count} reservations destroyed"
    end
    
end
