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
      security [ Bearer: [] ]

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
          expect([ 401, 403 ]).to include(response.status)
        end
      end

      response "401", "Unauthorized - invalid token" do
        let(:Authorization) { "Bearer invalid_token_here" }

        run_test! do
          expect([ 401, 403 ]).to include(response.status)
        end
      end
    end
  end

  path "/v1/employees/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Employee ID", example: 1

    get "Retrieves a specific employee by ID" do
      tags "Employees"
      consumes "application/json"
      produces "application/json"
      security [ Bearer: [] ]

      parameter name: :Authorization, in: :header, type: :string, required: true, description: "Bearer token"

      response "200", "Employee retrieved successfully" do
        let(:user) { create(:user, email_address: "john3@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }
        let(:employee) { create(:employee, email_address: "specific.employee@example.com", first_name: "Specific", last_name: "Employee") }
        let(:id) { employee.id }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to be_a(Hash)

          # Check that the employee has the expected structure
          expect(json_response).to have_key("id")
          expect(json_response).to have_key("email_address")
          expect(json_response).to have_key("first_name")
          expect(json_response).to have_key("last_name")
          expect(json_response).to have_key("phone_number")
          expect(json_response).to have_key("created_at")
          expect(json_response).to have_key("updated_at")
          expect(json_response).to have_key("type")

          # Verify specific employee data
          expect(json_response["id"]).to eq(employee.id)
          expect(json_response["email_address"]).to eq("specific.employee@example.com")
          expect(json_response["first_name"]).to eq("Specific")
          expect(json_response["last_name"]).to eq("Employee")
          expect(json_response["type"]).to eq("Employee")
        end
      end

      response "404", "Employee not found" do
        let(:user) { create(:user, email_address: "john4@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { 99999 }

        run_test! do
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("error")
          expect(json_response["error"]).to eq("Employee not found")
        end
      end

      response "401", "Unauthorized - missing token" do
        let(:employee) { create(:employee) }
        let(:id) { employee.id }
        let(:Authorization) { "" }

        run_test! do
          expect([ 401, 403 ]).to include(response.status)
        end
      end

      response "401", "Unauthorized - invalid token" do
        let(:employee) { create(:employee) }
        let(:id) { employee.id }
        let(:Authorization) { "Bearer invalid_token_here" }

        run_test! do
          expect([ 401, 403 ]).to include(response.status)
        end
      end
    end
  end
end
