require 'rails_helper'

RSpec.describe "Roles", type: :request, focus: true do
  include_context "db_cleanup_each"
  # let(:organizer) { apply_organizer(signup(FactoryGirl.attributes_for(:user)), Role) }
  let(:account) { signup FactoryGirl.attributes_for(:user) }

  context "quick API check" do
    # let!(:user) { login organizer }
    let!(:user) { login account }

    # organizer is  1 user + 1 role
    # then 5 roles are created for the same dummy user
    # then 5 more role entries are created to define the 'creator' of these 5 rows - issue of semantics?

    it_should_behave_like "resource index", :role
    it_should_behave_like "show resource", :role
    it_should_behave_like "create resource", :role
    it_should_behave_like "modifiable resource", :role
  end
end
