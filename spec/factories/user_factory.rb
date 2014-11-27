FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@nyu.edu" }
    firstname "Derek"
    lastname "Fisher"
    major "00000"
    patron_status "3"
    college "CO"
    department "00 "

    factory :undergraduate do
      patron_status "1"
    end

    factory :hasnt_been_used_undergrad do
      patron_status "2"
    end

    factory :no_bookings_undergrad do
      patron_status "2"
    end

    factory :nonadmin do
      admin_roles_mask nil
      patron_status "52"
    end

    factory :shanghai_undergraduate do
      firstname "Shangri"
      lastname "La"
      patron_status "0"
    end
    factory :admin do
      admin_roles_mask 1
      factory :ny_admin do
        admin_roles_mask 2
      end
      factory :shanghai_admin do
        admin_roles_mask 3
      end
    end
  end
end
