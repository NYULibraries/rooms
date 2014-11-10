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

u1 = User.new
u1.user_attributes = ":nyuidn: N00000000"
