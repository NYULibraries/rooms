FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@nyu.edu" }
    firstname "Derek"
    lastname "Fisher"
    user_attributes do
      {
        nyuidn: "BOR_ID",
        primary_institution: "INST01",
        institutions: ["INST01"],
        bor_status: "3",
        aleph_permissions: {}
      }
    end

    factory :undergraduate do
      user_attributes do
        {
          nyuidn: "BOR_ID",
          primary_institution: "INST01",
          institutions: ["INST01"],
          bor_status: "1",
          aleph_permissions: {}
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
