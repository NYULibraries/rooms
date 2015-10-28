namespace :rooms do
  namespace :transfer do

    desc "Dump data from database into YAML"
    task :dump, [:modelName] => :environment do |t, args|
      require "#{Rails.root}/app/models/roles/authorization.rb"
      require "#{Rails.root}/app/models/room.rb"
      require "#{Rails.root}/app/models/room_group.rb"

      args.with_defaults(:modelName => "Room")

      File.open("#{Rails.root}/lib/tasks/#{args[:modelName].downcase.pluralize}_#{Rails.env}.yml", 'w') do |file|
        thisModel = args[:modelName].camelize.constantize.all
        # pass the file handle as the second parameter to dump
        YAML::dump(thisModel, file)
      end

    end

    desc "Transfer room groups"
    task :room_groups => :environment do
      require "#{Rails.root}/app/models/roles/authorization.rb"
      require "#{Rails.root}/app/models/room.rb"
      require "#{Rails.root}/app/models/room_group.rb"
      room_groups = YAML.load_file("#{Rails.root}/lib/tasks/roomgroups_staging.yml")
      room_groups.each do |room_group|
        rg = RoomGroup.new
        rg.id = room_group.id
        rg.admin_roles_mask = room_group.admin_roles_mask
        rg.assign_attributes(room_group.attributes.except("admin_roles_mask", "id", "created_at", "updated_at"))
        rg.save!
      end
    end

    desc "Transfer rooms from dev to production based on ID matching"
    task :rooms => :environment do
      require "#{Rails.root}/app/models/roles/authorization.rb"
      require "#{Rails.root}/app/models/room.rb"
      require "#{Rails.root}/app/models/room_group.rb"
      rooms = YAML.load_file("#{Rails.root}/lib/tasks/rooms_staging.yml")
      rooms.each do |room|
        existing_room = Room.find_or_initialize_by_id(room.id)
        existing_room.assign_attributes(room.attributes.except("sort_order", "hours", "sort_size_of_room", "opens_at", "closes_at", "id", "created_at", "updated_at"))
        existing_room.opens_at = room.opens_at
        existing_room.closes_at = room.closes_at
        existing_room.sort_order = room.sort_order
        existing_room.hours = room.hours
        existing_room.sort_size_of_room = room.sort_size_of_room
        existing_room.save!
      end
    end

    desc "Get current rooms and their reservation count"
    task :reservation_count_dump => :environment do
      File.open("#{Rails.root}/lib/tasks/reservation_count_#{Rails.env}.yml", 'w') do |file|
        file.write(Room.all.map{|r| {:id => r.id, :count => r.reservations.count}}.to_yaml)
      end
    end

    desc "Test that reservation count hasn't changed from dump file"
    task :reservation_count => :environment do
      rooms = YAML.load_file("#{Rails.root}/lib/tasks/reservation_count_#{Rails.env}.yml")

      errored = false
      rooms.each do |r|
        room = Room.find(r[:id])
        if r[:count].to_i != room.reservations.count
          #puts "(#{room.id}) #{room.title} still has #{r[:count]}"
          #else
          puts "(#{room.id}) ERROR #{room.title} had #{r[:count]} but now has #{room.reservations.count}"
          errored = true
        end
      end
      puts "ALL FINE." unless errored
    end

  end
end
