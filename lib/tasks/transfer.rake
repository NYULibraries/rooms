require "#{Rails.root}/app/models/room.rb" unless Rails.env.test?

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
  
  desc "Transfer rooms from dev to production based on ID matching"
    task :rooms => :environment do
      rooms = YAML.load_file("#{Rails.root}/lib/tasks/rooms_development.yml")
      rooms.each do |room|
        existing_room = Room.find(room.id)
        existing_room.update_attributes(room)
      end
    end
  end
    
end
