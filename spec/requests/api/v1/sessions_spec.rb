require 'rails_helper'

RSpec.describe "API V1 Auth", type: :request do
  describe "POST /v1/auth/login" do
    it "creates a session with valid credentials" do
      # Create user with FactoryBot
      user = create(:user, email_address: "john@example.com", password: "password123")

      post v1_auth_login_path, params: {
        email_address: user.email_address,
        password: "password123"
      }

      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response).to have_key("token")
      expect(json_response["token"]).to be_present
    end

    it "does not create session with invalid credentials" do
      # Create user with FactoryBot
      user = create(:user, email_address: "john@example.com", password: "password123")

      post v1_auth_login_path, params: {
        email_address: user.email_address,
        password: "invalid"
      }

      expect([ 401, 403 ]).to include(response.status)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response).to have_key("error")
    end
  end

  describe "DELETE /v1/auth/logout" do
    it "destroys session with valid token" do
      # Create user and session with FactoryBot
      user = create(:user)
      session = create(:session, user: user)

      expect {
        delete v1_auth_logout_path, headers: {
          "Authorization" => "Bearer #{session.token}"
        }
      }.to change { Session.count }.by(-1)

      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response).to have_key("message")
    end

    it "does not destroy session with invalid token" do
      delete v1_auth_logout_path, headers: {
        "Authorization" => "Bearer invalid_token"
      }

      expect([401, 403]).to include(response.status)
    end
  end
end
