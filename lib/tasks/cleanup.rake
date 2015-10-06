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

    desc "Cleanup duplicate users to the oldest user and reassign reservations"
    task :duplicates => :environment do
      users_with_dupes = User.group(:username).having("count(*) > 1").order("created_at DESC")
      users_with_dupes.each do |user|
        dupes = User.where(username: user.username)
        new_user = dupes.first.dup
        puts "================="
        puts "Creating new user with #{new_user.username}"
        dupe_with_admin = dupes.find {|dupe| dupe.is_admin? }
        if dupe_with_admin
          puts "Assigning admin"
          new_user.admin_roles_mask = dupe_with_admin.admin_roles_mask
        end
        new_user.save!
        dupes.each do |dupe|
          puts "Reassigning #{dupe.reservations.count} reservations"
          dupe.reservations.each do |res|
            res.user = new_user
            res.save!
          end
        end
        dupes.delete_all
        puts "New user has #{new_user.reservations.count} reservations"
      end
    end

end
