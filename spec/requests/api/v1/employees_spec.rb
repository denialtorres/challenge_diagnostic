require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Employees API', type: :request do
  before(:each) do
    User.destroy_all
    Session.destroy_all
    Employee.destroy_all
  end

  path "/v1/employees" do
    get "Retrieves a list of all employees" do
      tags "Employees"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :Authorization, in: :header, type: :string, required: true, description: "Bearer token"

      response "200", "Employees list retrieved successfully" do
        let(:user) { create(:user, email_address: "john1@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }

        before do
          # Create some test employees
          create(:employee, email_address: "john.doe@example.com", first_name: "John", last_name: "Doe")
          create(:employee, email_address: "jane.smith@example.com", first_name: "Jane", last_name: "Smith")
          create(:employee, email_address: "bob.johnson@example.com", first_name: "Bob", last_name: "Johnson")
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to be_an(Array)
          expect(json_response.length).to eq(3)

          # Check that each employee has the expected structure
          json_response.each do |employee|
            expect(employee).to have_key("id")
            expect(employee).to have_key("email_address")
            expect(employee).to have_key("first_name")
            expect(employee).to have_key("last_name")
            expect(employee).to have_key("phone_number")
            expect(employee).to have_key("created_at")
            expect(employee).to have_key("updated_at")
            expect(employee).to have_key("type")
            expect(employee["type"]).to eq("Employee")
          end

          # Verify specific employee data
          john_employee = json_response.find { |emp| emp["first_name"] == "John" }
          expect(john_employee["email_address"]).to eq("john.doe@example.com")
          expect(john_employee["last_name"]).to eq("Doe")
        end
      end

      response "200", "Empty employees list when no employees exist" do
        let(:user) { create(:user, email_address: "john2@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to be_an(Array)
          expect(json_response.length).to eq(0)
        end
      end

      response "401", "Unauthorized - missing token" do
        let(:Authorization) { "" }

        run_test! do
          expect([401, 403]).to include(response.status)
        end
      end

      response "401", "Unauthorized - invalid token" do
        let(:Authorization) { "Bearer invalid_token_here" }

        run_test! do
          expect([401, 403]).to include(response.status)
        end
      end
    end
  end
end
