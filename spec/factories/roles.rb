FactoryGirl.define do
  factory :role do
    # association :user, factory: :dummy_user
    user_id { create(:dummy_user).id }
    role_name "organizer"
    mname "Role"

    trait :random do
      role_name { Faker::Job.position.parameterize }
    end

    after(:create) do |role|
      if role.mid.nil?
        role.update(mid: role.id)
      end
    end
  end
end
