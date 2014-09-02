FactoryGirl.define do
  factory :reservation do
    start_dt '3020-11-11 15:00:00'.to_time
    end_dt '3020-11-11 15:30:00'.to_time
    user
    room
  end

end
