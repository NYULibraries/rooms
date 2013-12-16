unless Rails.env.test?
require "#{Rails.root}/app/models/roles/authorization.rb"
require "#{Rails.root}/app/models/room.rb"
require "#{Rails.root}/app/models/room_group.rb"
end

namespace :transfer do

  desc "Dump data from database into YAML"
  task :dump, [:modelName] => :environment do |t, args|
    
    args.with_defaults(:modelName => "Room")

    File.open("#{Rails.root}/lib/tasks/#{args[:modelName].downcase.pluralize}_#{Rails.env}.yml", 'w') do |file|
      thisModel = args[:modelName].camelize.constantize.all
      # pass the file handle as the second parameter to dump
      YAML::dump(thisModel, file)
    end
    
  end

  desc "Transfer room groups"
  task :room_groups => :environment do
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
  

   
end
