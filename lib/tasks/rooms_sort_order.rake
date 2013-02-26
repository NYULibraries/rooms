namespace :rooms do
  desc "Update sort size of room fields"
  task :sort_order => :environment do
    Room.all.each do |room|
      room.touch
      room.save
    end
  end
end
