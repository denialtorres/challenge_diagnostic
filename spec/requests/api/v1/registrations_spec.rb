require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Registrations API', type: :request do
  before(:each) do
    User.destroy_all
    Session.destroy_all
  end

  path "/v1/auth/registrations" do
    post "Registers a new employee and returns authentication token" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :registration_params, in: :body, schema: {
        type: :object,
        properties: {
          email_address: { type: :string, format: :email, example: "john.doe@example.com" },
          password: { type: :string, format: :password, example: "password123" },
          password_confirmation: { type: :string, format: :password, example: "password123" },
          first_name: { type: :string, example: "John" },
          last_name: { type: :string, example: "Doe" },
          date_of_birth: { type: :string, format: :date, example: "1990-01-15" },
          phone_number: { type: :string, example: "5512345678" },
          international_code: { type: :string, example: "MX", enum: ["MX", "US", "CA"] }
        },
        required: [ "email_address", "password", "password_confirmation", "first_name", "last_name", "date_of_birth", "phone_number", "international_code" ]
      }

      response "201", "Employee created successfully" do
        let(:email_address) { "john.doe@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "5512345678" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("token")
          expect(json_response).to have_key("employee")
          expect(json_response["token"]).to be_present

          employee_data = json_response["employee"]
          expect(employee_data["email_address"]).to eq("john.doe@example.com")
          expect(employee_data["first_name"]).to eq("John")
          expect(employee_data["last_name"]).to eq("Doe")
          expect(employee_data["phone_number"]).to eq("+52 55 1234 5678")
          expect(employee_data["type"]).to eq("Employee")
        end
      end

      response "201", "Employee created successfully with US phone number" do
        let(:email_address) { "jane.smith@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "Jane" }
        let(:last_name) { "Smith" }
        let(:date_of_birth) { "1988-06-20" }
        let(:phone_number) { "2125551234" }
        let(:international_code) { "US" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          expect(json_response["employee"]["phone_number"]).to eq("+1 (212) 555-1234")
        end
      end

      response "201", "Employee created successfully with Canadian phone number" do
        let(:email_address) { "bob.johnson@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "Bob" }
        let(:last_name) { "Johnson" }
        let(:date_of_birth) { "1985-12-01" }
        let(:phone_number) { "6045551234" }
        let(:international_code) { "CA" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          expect(json_response["employee"]["phone_number"]).to eq("+1 (604) 555-1234")
        end
      end

      response "422", "Validation error - missing first_name" do
        let(:email_address) { "test@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "5512345678" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to include("First name can't be blank")
        end
      end

      response "422", "Validation error - missing last_name" do
        let(:email_address) { "test@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "John" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "5512345678" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to include("Last name can't be blank")
        end
      end

      response "422", "Validation error - missing date_of_birth" do
        let(:email_address) { "test@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:phone_number) { "5512345678" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to include("Date of birth can't be blank")
        end
      end

      response "422", "Validation error - missing phone_number" do
        let(:email_address) { "test@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to include("Phone number can't be blank")
        end
      end

      response "422", "Validation error - invalid email format" do
        let(:email_address) { "not-an-email" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "5512345678" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to include("Email address is not a valid email address")
        end
      end

      response "422", "Validation error - phone number too short" do
        let(:email_address) { "john.doe@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "123" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to include("Phone number is not a valid phone number")
        end
      end

      response "422", "Validation error - phone number with letters" do
        let(:email_address) { "john.doe@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "abc123def" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to include("Phone number is not a valid phone number")
        end
      end

      response "422", "Validation error - invalid international_code" do
        let(:email_address) { "john.doe@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "5512345678" }
        let(:international_code) { "INVALID" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to include("International code is not a supported country")
        end
      end

      response "422", "Validation error - password too short" do
        let(:email_address) { "john.doe@example.com" }
        let(:password) { "123" }
        let(:password_confirmation) { "123" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "5512345678" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to be_present
        end
      end

      response "422", "Validation error - password confirmation doesn't match" do
        let(:email_address) { "john.doe@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "different_password" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "5512345678" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to be_present
        end
      end

      response "422", "Multiple validation errors" do
        let(:email_address) { "invalid-email" }
        let(:password) { "123" }
        let(:password_confirmation) { "different" }
        let(:phone_number) { "abc123" }
        let(:international_code) { "WRONG" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to be_an(Array)
          expect(json_response["error"].length).to be > 1
        end
      end

      response "422", "Validation error - duplicate email address" do
        let(:email_address) { "duplicate@example.com" }
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }
        let(:first_name) { "John" }
        let(:last_name) { "Doe" }
        let(:date_of_birth) { "1990-01-15" }
        let(:phone_number) { "5512345678" }
        let(:international_code) { "MX" }
        let(:registration_params) { { email_address: email_address, password: password,
                                      password_confirmation: password_confirmation, first_name: first_name,
                                      last_name: last_name, date_of_birth: date_of_birth,
                                      phone_number: phone_number, international_code: international_code
                                    } }

        before do
          create(:employee, email_address: "duplicate@example.com")
        end

        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
          json_response = JSON.parse(response.body)
          expect(json_response["error"]).to be_present
        end
      end
    end
  end
end
