FactoryGirl.define do
  factory :role do
    # association :user, factory: :dummy_user
    user_id { create(:dummy_user).id }
    role_name "organizer"
    mname "Role"
    after(:create) do |role|
      if role.mid.nil?
        role.update(mid: role.id)
      end
    end
  end
end
