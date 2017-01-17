require 'rails_helper'

RSpec.describe "FooApiErrorReportings", type: :request do
  describe "POST /api/foos" do
    it "invalid Foo reports API error" do
      post foos_path, {foo: {id: 1} },
                     {"Accept"=>"application/json"}
      expect([404,422]).to include(response.code.to_i)

      payload = parsed_body
      expect(payload).to have_key("errors")
    end
  end
end
