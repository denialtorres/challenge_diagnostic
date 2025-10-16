require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Sessions API', type: :request do
  before(:each) do
    User.destroy_all
    Session.destroy_all
  end

  path "/v1/auth/login" do
    post "Authenticates user and creates session" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :user_params, in: :body, schema: {
         type: :object,
         properties: {
           email_address: { type: :string, format: :email, example: "test@example.com" },
           password: { type: :string, format: :password, example: "password123" }
         },
         required: [ "email_address", "password" ]
       }

      response "200", "Session created successfully" do
        let(:email_address) { "john@example.com" }
        let(:password) { "password123" }
        let(:user_params) { { email_address: email_address, password: password } }

        before do
          create(:user, email_address: "john@example.com", password: "password123")
        end

        run_test! do
          expect(response).to have_http_status(:success)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("token")
          expect(json_response["token"]).to be_present
        end
      end

      response "401", "Invalid credentials" do
        let(:email_address) { "john@example.com" }
        let(:password) { "invalid" }
        let(:user_params) { { email_address: email_address, password: password } }

        before do
          create(:user, email_address: "john@example.com", password: "password123")
        end

        run_test! do
          expect([ 401, 403 ]).to include(response.status)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("error")
        end
      end
    end
  end

  path "/v1/auth/logout" do
    delete "Destroys user session" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      security [ Bearer: [] ]

      parameter name: :Authorization, in: :header, type: :string,
                description: "Bearer token for authentication",
                example: "Bearer your_token_here"

      response "200", "Session destroyed successfully" do
        let(:user) { create(:user) }
        let(:session) { create(:session, user: user) }
        let(:Authorization) { "Bearer #{session.token}" }

        run_test! do
          expect(response).to have_http_status(:success)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("message")
          expect(Session.find_by(token: session.token)).to be_nil
        end
      end

      response "401", "Invalid or missing token" do
        let(:Authorization) { "Bearer invalid_token" }

        run_test! do
          expect([ 401, 403 ]).to include(response.status)
        end
      end
    end
  end
end
