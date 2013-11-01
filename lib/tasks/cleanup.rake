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
    
    desc "Rewrite rooms hours hash as two string fields hours_start and hours_end"
    task :rooms_hours => :environment do
      Room.all.each do |r|
        hour_start = (r.hours[:hours_start][:ampm] == "pm" && r.hours[:hours_start][:hour] != "12") ? r.hours[:hours_start][:hour].to_i + 12 :
                      (r.hours[:hours_start][:ampm] == "am" && r.hours[:hours_start][:hour] == "12") ? hour = 0 :
                        r.hours[:hours_start][:hour]
        hour_end = (r.hours[:hours_end][:ampm] == "pm" && r.hours[:hours_end][:hour] != "12") ? r.hours[:hours_end][:hour].to_i + 12 :
                      (r.hours[:hours_end][:ampm] == "am" && r.hours[:hours_end][:hour] == "12") ? hour = 0 :
                        r.hours[:hours_end][:hour]
        r.opens_at = "#{hour_start.to_s.rjust(2, '0')}:#{r.hours[:hours_start][:minute].to_s.rjust(2, '0')}"
        r.closes_at = "#{hour_end.to_s.rjust(2, '0') }:#{r.hours[:hours_end][:minute].to_s.rjust(2, '0')}"
        r.save!
      end
    end
      
end