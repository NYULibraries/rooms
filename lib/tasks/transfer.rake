require "#{Rails.root}/app/models/room.rb"

namespace :transfer do

  desc "Dump data from database into YAML"
  task :dump, [:modelName] => :environment do |t, args|
    
    args.with_defaults(:modelName => "Room")

    File.open("#{RAILS_ROOT}/lib/tasks/#{args[:modelName].downcase.pluralize}_#{RAILS_ENV}.yml", 'w') do |file|
      thisModel = args[:modelName].camelize.constantize.all
      # pass the file handle as the second parameter to dump
      YAML::dump(thisModel, file)
    end
    
  end
  
  desc "Transfer rooms from dev to production based on title matching, keep old title"
  task :rooms => :environment do
    
    rooms = YAML.load_file("#{RAILS_ROOT}/lib/tasks/rooms_development.yml")
    i = 0
    rooms.each do |r|
      title_match = r.title.match(/\s\d{3}|LL\d-\d(\d|\w)/)
      existing_room = Room.find(:all, :conditions => "title like '%#{r.title}%'") if title_match.nil?
      existing_room = Room.find(:all, :conditions => "title like '%#{title_match}%'") unless title_match.nil?
      if existing_room.count == 1
        i += 1
        old_room = existing_room.first
        old_room.sort_order = r.sort_order
        old_room.description = r.description
        old_room.type_of_room = r.type_of_room
        old_room.size_of_room = r.size_of_room
        old_room.image_link = r.image_link
        old_room.hours = r.hours
        old_room.save
      end

    end
  
  end
  
  desc "Transfer room titles"
  task :room_titles => :environment do
    
    rooms = YAML.load_file("#{RAILS_ROOT}/lib/tasks/rooms_development.yml")
    i = 0
    rooms.each do |r|
      title_match = r.title.match(/\s\d{3}|LL\d-\d(\d|\w)/)
      existing_room = Room.find(:all, :conditions => "title like '%#{r.title}%'") if title_match.nil?
      existing_room = Room.find(:all, :conditions => "title like '%#{title_match}%'") unless title_match.nil?
      if existing_room.count == 1
        i += 1
        old_room = existing_room.first
        old_room.title = r.title
        old_room.save
      end

    end
  
  end
  
end