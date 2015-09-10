FactoryGirl.define do
  factory :room_group do
    title "Graduate"
    admin_roles_mask 1
    code "ny_graduate"

    factory :undergraduate_room_group do
      title "Undergraduate"
      code "ny_undergraduate"
    end

    factory :shanghai_room_group do
      title "Shanghai"
      admin_roles_mask 5
      code "shanghai_undergraduate"
    end
  end
end
