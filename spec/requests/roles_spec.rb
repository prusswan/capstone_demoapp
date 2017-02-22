require 'rails_helper'

RSpec.describe "Roles", type: :request do
  include_context "db_cleanup_each"
  let(:originator) { apply_originator(signup(FactoryGirl.attributes_for(:user)), Role) }

  context "quick API check" do
    let!(:user) { login originator }

    it_should_behave_like "resource index", :role
    it_should_behave_like "show resource", :role
    it_should_behave_like "create resource", :role
    it_should_behave_like "modifiable resource", :role
  end
end
