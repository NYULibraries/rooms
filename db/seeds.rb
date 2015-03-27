# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

rg1 = RoomGroup.new
rg1.admin_roles = ["global", "ny_admin"]
rg1.title = "NY Graduate"
rg1.code = "ny_graduate"
rg1.save

rg2 = RoomGroup.new
rg2.admin_roles = ["global", "ny_admin"]
rg2.title = "NY Undergraduate"
rg2.code = "ny_undergraduate"
rg2.save

rg2 = RoomGroup.new
rg2.admin_roles = ["global", "shanghai_admin"]
rg2.title = "Shanghai Undergraduate"
rg2.code = "shanghai_undergraduate"
rg2.save



private

def room_hash(options = {})
  {
    title: Faker::Lorem.word,
    description: Faker::Hacker.say_something_smart,
    type_of_room: 'Graduate Study',
    size_of_room: "1-2 people",
    hours:"7:00 am - 1:00 am",
    opens_at: "7:00 am",
    closes_at: "1:00 am",
    collaborative: false,
    room_group_id: 2
  }.merge(options)
end

def room_with_image_hash
  room_hash({image_link: "google.com"})
end

def grad_collaborative_hash
  room_hash({
      type_of_room: 'Grad Collaborative',
      size_of_room: ["6 people", "12 people"].sample,
      collaborative: true,
      room_group_id: 1
    })
end

def group_study_hash
  room_hash({
      type_of_room: 'Group Study Room',
      size_of_room: ["3-6 people", "7-11 people"].sample,
      hours:"Open 24 hours",
      collaborative: true
    })
end

def user_hash(options = {})
  name = Faker::Name
  {
    firstname: name.first_name,
    lastname: name.last_name,
    email: Faker::Internet.email(name),
    username: Faker::Internet.user_name(name),
    persistence_token: "",
    user_attributes:{
      bor_status: "57"
    }
  }.merge(options)
end

def dev_user_hash
  user_hash({
      :email => "user@nyu.edu",
      :firstname => "Ptolemy",
      :username => "ppXX"
    })
end

if Rails.env.development? || Rails.env.test?
  User.create(dev_user_hash)
  Room.create(room_with_image_hash)
  (1..1000).each do
    User.create(user_hash)
  end
  (1..30).each do
    Room.create(room_hash)
  end
  (1..20).each do
    Room.create(group_study_hash)
    Room.create(grad_collaborative_hash)
  end
end
