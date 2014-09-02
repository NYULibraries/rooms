FactoryGirl.define do
  factory :room do
    title "Room 1"
    type_of_room "One person"
    size_of_room "1-2 People"
    sort_size_of_room 2
    sort_order 1
    opens_at '07:00'
    closes_at '01:00'
    room_group
  end
end
