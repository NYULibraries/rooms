namespace :rooms do
  namespace :upgrade do

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

    desc "Add room group to all rooms"
    task :add_room_group => :environment do
      room_group = RoomGroup.where(:code => "ny_graduate").first
      Room.update_all(:room_group_id => room_group.id)
    end

    desc "Make old admins into new admins"
    task :update_admins => :environment do
      User.where("user_attributes LIKE '%:room_reserve_admin: true%'").update_all(:admin_roles_mask => 1)
    end

    desc "Populate collaborative flag from pattern matching title"
    task :collaborative_flag => :environment do
      Room.where("type_of_room LIKE '%Collaborative%'").update_all(:collaborative => true)
    end

  end
end
