require 'rails_helper'

RSpec.describe "API V1 Sessions", type: :request do
  describe "POST /v1/session" do
    it "creates a session with valid credentials" do
      # Create user directly in the test
      user = User.create!(
        email_address: "john@example.com",
        password: "password123"
      )

      post v1_session_path, params: {
        email_address: "john@example.com",
        password: "password123"
      }

      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response).to have_key("token")
      expect(json_response["token"]).to be_present
    end

    it "does not create session with invalid credentials" do
      # Create user directly in the test
      user = User.create!(
        email_address: "john@example.com",
        password: "password123"
      )

      post v1_session_path, params: {
        email_address: "john@example.com",
        password: "invalid"
      }

      expect([401, 403]).to include(response.status)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response).to have_key("error")
    end
  end

  describe "DELETE /v1/session" do
    it "destroys session with valid token" do
      # Create user and session directly in the test
      user = User.create!(
        email_address: "john@example.com",
        password: "password123"
      )

      session = user.sessions.create!(
        user_agent: "Test Browser",
        ip_address: "127.0.0.1"
      )

      expect {
        delete v1_session_path, headers: {
          "Authorization" => "Bearer #{session.token}"
        }
      }.to change { Session.count }.by(-1)

      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response).to have_key("message")
    end

    it "does not destroy session with invalid token" do
      delete v1_session_path, headers: {
        "Authorization" => "Bearer invalid_token"
      }

      expect([401, 403]).to include(response.status)
    end
  end
end
