require 'rails_helper'

RSpec.describe "Users", type: :request do
  include_context "db_cleanup_each"

  describe "User authorization" do
    context "caller is anonymous" do
      it "cannot index" do
        jget send("users_path"), {}, {"Accept"=>"application/json"}
        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body).to include("errors")
      end
    end

    context "caller is authenticated no role" do
      let(:user) { resources.first.attributes }
      let(:user_without_role) { resources.last }

      before { login user_without_role }

      it_should_behave_like "resource index", :user
    end
  end
end
