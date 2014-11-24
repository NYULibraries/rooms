FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@nyu.edu" }
    firstname "Derek"
    lastname "Fisher"
    user_attributes do
      {
        type: "",
        major: "00000",
        status: "3",
        college: "CO",
        department: "00 ",
        identifier: "N00000000",
        ill_library: "LIBRARY",
        plif_status: "PLIF STATUS",
        ill_permission: "?"
      }
    end

    factory :undergraduate do
      user_attributes do
        {
          type: "",
          major: "00000",
          status: "1",
          college: "CO",
          department: "00 ",
          identifier: "N00000000",
          ill_library: "LIBRARY",
          plif_status: "PLIF STATUS",
          ill_permission: "?"
        }
      end
    end

    factory :hasnt_been_used_undergrad do
      user_attributes do
        {
          type: "",
          major: "00000",
          status: "2",
          college: "CO",
          department: "00 ",
          identifier: "N00000000",
          ill_library: "LIBRARY",
          plif_status: "PLIF STATUS",
          ill_permission: "?"
        }
      end
    end

    factory :no_bookings_undergrad do
      user_attributes do
        {
          type: "",
          major: "00000",
          status: "2",
          college: "CO",
          department: "00 ",
          identifier: "N00000000",
          ill_library: "LIBRARY",
          plif_status: "PLIF STATUS",
          ill_permission: "?"
        }
      end
    end

    factory :nonadmin do
      admin_roles_mask nil
      user_attributes do
        {
          type: "",
          major: "00000",
          status: "52",
          college: "CO",
          department: "00 ",
          identifier: "N00000000",
          ill_library: "LIBRARY",
          plif_status: "PLIF STATUS",
          ill_permission: "?"
        }
      end
    end

    factory :shanghai_undergraduate do
      firstname "Shangri"
      lastname "La"
      user_attributes do
        {
          type: "",
          major: "00000",
          status: "0",
          college: "CO",
          department: "00 ",
          identifier: "N00000000",
          ill_library: "LIBRARY",
          plif_status: "PLIF STATUS",
          ill_permission: "?"
        }
      end
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
