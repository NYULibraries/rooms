def time_rand from = Time.now, to = 5.days.from_now
  Time.at(from + rand * (to.to_f - from.to_f))
end

FactoryBot.define do
  factory :reservation do
    start_dt (@time = Faker::Time.forward(30, :afternoon))
    end_dt (@time + 90.minutes)
    user
    room
  end

  factory :block, class: Reservation do
    start_dt (@time = Faker::Time.forward(30, :afternoon))
    end_dt (@time + 90.minutes)
    user
    room
    is_block true
  end
end
