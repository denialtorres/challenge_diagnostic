require 'rails_helper'

RSpec.describe "API V1 Auth Registrations", type: :request do
  before(:each) do
    User.destroy_all
    Session.destroy_all
  end

  describe "POST /v1/auth/registrations" do
    context "with valid employee data" do
      it "creates an employee and returns token with employee data" do
        post v1_auth_registrations_path, params: {
          email_address: "john.doe@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          phone_number: "5512345678",
          international_code: "MX"
        }

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

      it "creates an employee with US phone number" do
        post v1_auth_registrations_path, params: {
          email_address: "jane.smith@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "Jane",
          last_name: "Smith",
          date_of_birth: "1988-06-20",
          phone_number: "2125551234",
          international_code: "US"
        }

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["employee"]["phone_number"]).to eq("+1 (212) 555-1234")
      end

      it "creates an employee with Canadian phone number" do
        post v1_auth_registrations_path, params: {
          email_address: "bob.johnson@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "Bob",
          last_name: "Johnson",
          date_of_birth: "1985-12-01",
          phone_number: "6045551234",
          international_code: "CA"
        }

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["employee"]["phone_number"]).to eq("+1 (604) 555-1234")
      end
    end

    context "with missing required fields" do
      it "returns error when first_name is missing" do
        post v1_auth_registrations_path, params: {
          email_address: "test@example.com",
          password: "password123",
          password_confirmation: "password123",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          phone_number: "5512345678",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("First name can't be blank")
      end

      it "returns error when last_name is missing" do
        post v1_auth_registrations_path, params: {
          email_address: "test@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          date_of_birth: "1990-01-15",
          phone_number: "5512345678",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Last name can't be blank")
      end

      it "returns error when date_of_birth is missing" do
        post v1_auth_registrations_path, params: {
          email_address: "test@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe",
          phone_number: "5512345678",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Date of birth can't be blank")
      end

      it "returns error when phone_number is missing" do
        post v1_auth_registrations_path, params: {
          email_address: "test@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Phone number can't be blank")
      end
    end

    context "with invalid email format" do
      it "returns error for invalid email" do
        post v1_auth_registrations_path, params: {
          email_address: "not-an-email",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          phone_number: "5512345678",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Email address is not a valid email address")
      end
    end

    context "with invalid phone number" do
      it "returns error for phone number too short" do
        post v1_auth_registrations_path, params: {
          email_address: "john.doe@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          phone_number: "123",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Phone number is not a valid phone number")
      end

      it "returns error for phone number with letters" do
        post v1_auth_registrations_path, params: {
          email_address: "john.doe@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          phone_number: "abc123def",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Phone number is not a valid phone number")
      end
    end

    context "with invalid country code" do
      it "returns error for invalid international_code" do
        post v1_auth_registrations_path, params: {
          email_address: "john.doe@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          phone_number: "5512345678",
          international_code: "INVALID"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("International code is not a supported country")
      end
    end

    context "with password validation errors" do
      it "returns error when password is too short" do
        post v1_auth_registrations_path, params: {
          email_address: "john.doe@example.com",
          password: "123",
          password_confirmation: "123",
          first_name: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          phone_number: "5512345678",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to be_present
      end

      it "returns error when password confirmation doesn't match" do
        post v1_auth_registrations_path, params: {
          email_address: "john.doe@example.com",
          password: "password123",
          password_confirmation: "different_password",
          first_name: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          phone_number: "5512345678",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to be_present
      end
    end

    context "with multiple validation errors" do
      it "returns all validation errors" do
        post v1_auth_registrations_path, params: {
          email_address: "invalid-email",
          password: "123",
          password_confirmation: "different",
          phone_number: "abc123",
          international_code: "WRONG"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to be_an(Array)
        expect(json_response["error"].length).to be > 1
      end
    end

    context "with duplicate email address" do
      it "handles duplicate email gracefully" do
        # First, create an employee
        create(:employee, email_address: "duplicate@example.com")

        # Try to create another with same email
        post v1_auth_registrations_path, params: {
          email_address: "duplicate@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-15",
          phone_number: "5512345678",
          international_code: "MX"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to be_present
      end
    end
  end
end
