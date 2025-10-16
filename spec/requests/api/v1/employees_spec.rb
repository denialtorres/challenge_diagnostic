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
      parameter name: :page_token, in: :query, type: :string, required: false, description: "Token for cursor-based pagination"

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
          expect(json_response).to have_key("data")
          expect(json_response["data"]).to be_a(Hash)
          expect(json_response["data"]["type"]).to eq("paginated_employees")
          expect(json_response["data"]["attributes"]).to have_key("employees")
          expect(json_response["data"]["attributes"]).to have_key("page_info")

          # Check pagination info
          page_info = json_response["data"]["attributes"]["page_info"]
          expect(page_info).to have_key("page_records")
          expect(page_info).to have_key("next_page_token")
          expect(page_info).to have_key("previous_page_token")
          expect(page_info["page_records"]).to eq(3)

          # Check employees array
          employees = json_response["data"]["attributes"]["employees"]
          expect(employees).to be_an(Array)
          expect(employees.length).to eq(3)

          # Check that each employee has the expected structure
          employees.each do |employee|
            expect(employee).to have_key("id")
            expect(employee).to have_key("type")
            expect(employee).to have_key("attributes")
            expect(employee["type"]).to eq("employee")

            attributes = employee["attributes"]
            expect(attributes).to have_key("email_address")
            expect(attributes).to have_key("first_name")
            expect(attributes).to have_key("last_name")
            expect(attributes).to have_key("phone_number")
            expect(attributes).to have_key("created_at")
            expect(attributes).to have_key("updated_at")
            expect(attributes).to have_key("type")
            expect(attributes["type"]).to eq("Employee")
          end

          # Verify specific employee data
          john_employee = employees.find { |emp| emp["attributes"]["first_name"] == "John" }
          expect(john_employee["attributes"]["email_address"]).to eq("john.doe@example.com")
          expect(john_employee["attributes"]["last_name"]).to eq("Doe")
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
          expect(json_response).to have_key("data")
          expect(json_response["data"]).to be_a(Hash)
          expect(json_response["data"]["type"]).to eq("paginated_employees")
          expect(json_response["data"]["attributes"]).to have_key("employees")
          expect(json_response["data"]["attributes"]).to have_key("page_info")

          # Check pagination info
          page_info = json_response["data"]["attributes"]["page_info"]
          expect(page_info["page_records"]).to eq(0)

          # Check employees array is empty
          employees = json_response["data"]["attributes"]["employees"]
          expect(employees).to be_an(Array)
          expect(employees.length).to eq(0)
        end
      end

      response "200", "Paginated employees list with cursor navigation" do
        let(:user) { create(:user, email_address: "john3@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }

        before do
          # Create 15 employees to test pagination (limit is 10 per page)
          15.times do |i|
            create(:employee,
              email_address: "employee#{i + 1}@example.com",
              first_name: "Employee",
              last_name: "#{i + 1}",
              phone_number: "55123456#{format('%02d', i + 10)}",
              international_code: "MX"
            )
          end
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("data")
          expect(json_response["data"]["type"]).to eq("paginated_employees")

          # Check pagination info for first page
          page_info = json_response["data"]["attributes"]["page_info"]
          expect(page_info["page_records"]).to eq(10) # Should have 10 records (limit)
          expect(page_info["next_page_token"]).not_to be_nil # Should have next page
          expect(page_info["previous_page_token"]).to be_nil # First page has no previous

          # Check employees array
          employees = json_response["data"]["attributes"]["employees"]
          expect(employees).to be_an(Array)
          expect(employees.length).to eq(10)

          # Test navigation to second page using page_token
          next_page_token = page_info["next_page_token"]
          get "/v1/employees", params: { page_token: next_page_token },
              headers: { "Authorization" => "Bearer #{token}" }

          expect(response).to have_http_status(:ok)
          second_page_response = JSON.parse(response.body)

          second_page_info = second_page_response["data"]["attributes"]["page_info"]
          expect(second_page_info["page_records"]).to eq(5) # Remaining 5 records
          expect(second_page_info["next_page_token"]).to be_nil # Last page has no next
          expect(second_page_info["previous_page_token"]).not_to be_nil # Should have previous

          second_page_employees = second_page_response["data"]["attributes"]["employees"]
          expect(second_page_employees.length).to eq(5)

          # Verify no duplicate employees between pages
          first_page_ids = employees.map { |emp| emp["id"] }
          second_page_ids = second_page_employees.map { |emp| emp["id"] }
          expect(first_page_ids & second_page_ids).to be_empty
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

      post "Creates a new employee" do
        tags "Employees"
        consumes "application/json"
        produces "application/json"
        security [ Bearer: [] ]

        parameter name: :Authorization, in: :header, type: :string, required: true, description: "Bearer token"
        parameter name: :employee_params, in: :body, schema: {
          type: :object,
          properties: {
            email_address: { type: :string, format: :email, example: "new.employee@example.com" },
            password: { type: :string, format: :password, example: "password123" },
            password_confirmation: { type: :string, format: :password, example: "password123" },
            first_name: { type: :string, example: "New" },
            last_name: { type: :string, example: "Employee" },
            date_of_birth: { type: :string, format: :date, example: "1992-05-20" },
            phone_number: { type: :string, example: "5587654321" },
            international_code: { type: :string, example: "MX", enum: [ "MX", "US", "CA" ] }
          },
          required: [ "email_address", "password", "password_confirmation", "first_name", "last_name", "date_of_birth", "phone_number", "international_code" ]
        }

        response "201", "Employee created successfully" do
          let(:user) { create(:user, email_address: "john5@example.com", password: "password123") }
          let(:session_record) { create(:session, user: user) }
          let(:token) { session_record.token }
          let(:Authorization) { "Bearer #{token}" }
          let(:email_address) { "new.employee@example.com" }
          let(:password) { "password123" }
          let(:password_confirmation) { "password123" }
          let(:first_name) { "New" }
          let(:last_name) { "Employee" }
          let(:date_of_birth) { "1992-05-20" }
          let(:phone_number) { "5587654321" }
          let(:international_code) { "MX" }
          let(:employee_params) { { email_address: email_address, password: password,
                                    password_confirmation: password_confirmation, first_name: first_name,
                                    last_name: last_name, date_of_birth: date_of_birth,
                                    phone_number: phone_number, international_code: international_code
                                  } }

          run_test! do
            expect(response).to have_http_status(:created)
            expect(response.content_type).to match(a_string_including("application/json"))

            json_response = JSON.parse(response.body)
            expect(json_response).to have_key("data")

            employee = json_response["data"]
            expect(employee).to have_key("id")
            expect(employee).to have_key("type")
            expect(employee).to have_key("attributes")
            expect(employee["type"]).to eq("employee")

            attributes = employee["attributes"]
            expect(attributes).to have_key("email_address")
            expect(attributes).to have_key("first_name")
            expect(attributes).to have_key("last_name")
            expect(attributes).to have_key("phone_number")
            expect(attributes).to have_key("created_at")
            expect(attributes).to have_key("updated_at")
            expect(attributes).to have_key("type")

            # Verify specific employee data
            expect(attributes["email_address"]).to eq("new.employee@example.com")
            expect(attributes["first_name"]).to eq("New")
            expect(attributes["last_name"]).to eq("Employee")
            expect(attributes["phone_number"]).to eq("+52 55 8765 4321")
            expect(attributes["type"]).to eq("Employee")
          end
        end

        response "422", "Validation error - missing required fields" do
          let(:user) { create(:user, email_address: "john6@example.com", password: "password123") }
          let(:session_record) { create(:session, user: user) }
          let(:token) { session_record.token }
          let(:Authorization) { "Bearer #{token}" }
          let(:email_address) { "incomplete@example.com" }
          let(:password) { "password123" }
          let(:password_confirmation) { "password123" }
          let(:employee_params) { { email_address: email_address, password: password,
                                    password_confirmation: password_confirmation
                                  } }

          run_test! do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to match(a_string_including("application/json"))

            json_response = JSON.parse(response.body)
            expect(json_response).to have_key("error")
            expect(json_response["error"]).to be_an(Array)
            expect(json_response["error"]).to include("First name can't be blank")
            expect(json_response["error"]).to include("Last name can't be blank")
          end
        end

        response "422", "Validation error - duplicate email address" do
          let(:user) { create(:user, email_address: "john7@example.com", password: "password123") }
          let(:session_record) { create(:session, user: user) }
          let(:token) { session_record.token }
          let(:Authorization) { "Bearer #{token}" }
          let(:email_address) { "duplicate.create@example.com" }
          let(:password) { "password123" }
          let(:password_confirmation) { "password123" }
          let(:first_name) { "Duplicate" }
          let(:last_name) { "Employee" }
          let(:date_of_birth) { "1990-01-01" }
          let(:phone_number) { "5512345678" }
          let(:international_code) { "MX" }
          let(:employee_params) { { email_address: email_address, password: password,
                                    password_confirmation: password_confirmation, first_name: first_name,
                                    last_name: last_name, date_of_birth: date_of_birth,
                                    phone_number: phone_number, international_code: international_code
                                  } }

          before do
            create(:employee, email_address: "duplicate.create@example.com")
          end

          run_test! do
            expect(response).to have_http_status(:unprocessable_entity)
            json_response = JSON.parse(response.body)
            expect(json_response).to have_key("error")
            expect(json_response["error"]).to include("Email address has already been taken")
          end
        end

        response "401", "Unauthorized - missing token" do
          let(:Authorization) { "" }
          let(:employee_params) { { email_address: "test@example.com", password: "password123",
                                    password_confirmation: "password123", first_name: "Test",
                                    last_name: "User", date_of_birth: "1990-01-01",
                                    phone_number: "5512345678", international_code: "MX"
                                  } }

          run_test! do
            expect([ 401, 403 ]).to include(response.status)
          end
        end

        response "401", "Unauthorized - invalid token" do
          let(:Authorization) { "Bearer invalid_token_here" }
          let(:employee_params) { { email_address: "test@example.com", password: "password123",
                                    password_confirmation: "password123", first_name: "Test",
                                    last_name: "User", date_of_birth: "1990-01-01",
                                    phone_number: "5512345678", international_code: "MX"
                                  } }

          run_test! do
            expect([ 401, 403 ]).to include(response.status)
          end
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
          expect(json_response).to have_key("data")

          emp_data = json_response["data"]
          expect(emp_data).to have_key("id")
          expect(emp_data).to have_key("type")
          expect(emp_data).to have_key("attributes")
          expect(emp_data["type"]).to eq("employee")

          attributes = emp_data["attributes"]
          expect(attributes).to have_key("email_address")
          expect(attributes).to have_key("first_name")
          expect(attributes).to have_key("last_name")
          expect(attributes).to have_key("phone_number")
          expect(attributes).to have_key("created_at")
          expect(attributes).to have_key("updated_at")
          expect(attributes).to have_key("type")

          # Verify specific employee data
          expect(emp_data["id"].to_i).to eq(employee.id)
          expect(attributes["email_address"]).to eq("specific.employee@example.com")
          expect(attributes["first_name"]).to eq("Specific")
          expect(attributes["last_name"]).to eq("Employee")
          expect(attributes["type"]).to eq("Employee")
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

    put "Updates an existing employee" do
      tags "Employees"
      consumes "application/json"
      produces "application/json"
      security [ Bearer: [] ]

      parameter name: :Authorization, in: :header, type: :string, required: true, description: "Bearer token"
      parameter name: :employee_params, in: :body, schema: {
        type: :object,
        properties: {
          email_address: { type: :string, format: :email, example: "updated.employee@example.com" },
          first_name: { type: :string, example: "Updated" },
          last_name: { type: :string, example: "Employee" },
          date_of_birth: { type: :string, format: :date, example: "1990-01-01" },
          phone_number: { type: :string, example: "5599887766" },
          international_code: { type: :string, example: "MX", enum: [ "MX", "US", "CA" ] }
        }
      }

      response "200", "Employee updated successfully" do
        let(:user) { create(:user, email_address: "john8@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }
        let(:employee) { create(:employee, email_address: "original.employee@example.com", first_name: "Original", last_name: "Employee") }
        let(:id) { employee.id }
        let(:first_name) { "Updated" }
        let(:last_name) { "Employee" }
        let(:phone_number) { "5599887766" }
        let(:international_code) { "MX" }
        let(:employee_params) { { first_name: first_name, last_name: last_name,
                                  phone_number: phone_number, international_code: international_code
                                } }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("data")

          emp_data = json_response["data"]
          expect(emp_data).to have_key("id")
          expect(emp_data).to have_key("type")
          expect(emp_data).to have_key("attributes")
          expect(emp_data["type"]).to eq("employee")

          attributes = emp_data["attributes"]
          expect(attributes).to have_key("email_address")
          expect(attributes).to have_key("first_name")
          expect(attributes).to have_key("last_name")
          expect(attributes).to have_key("phone_number")
          expect(attributes).to have_key("created_at")
          expect(attributes).to have_key("updated_at")
          expect(attributes).to have_key("type")

          # Verify updated employee data
          expect(emp_data["id"].to_i).to eq(employee.id)
          expect(attributes["email_address"]).to eq("original.employee@example.com") # unchanged
          expect(attributes["first_name"]).to eq("Updated")
          expect(attributes["last_name"]).to eq("Employee")
          expect(attributes["phone_number"]).to eq("+52 55 9988 7766")
          expect(attributes["type"]).to eq("Employee")

          # Verify employee was actually updated in database
          updated_employee = Employee.find(employee.id)
          expect(updated_employee.first_name).to eq("Updated")
        end
      end

      response "200", "Employee updated with partial data" do
        let(:user) { create(:user, email_address: "john9@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }
        let(:employee) { create(:employee, email_address: "partial.employee@example.com", first_name: "Original", last_name: "Name") }
        let(:id) { employee.id }
        let(:first_name) { "OnlyFirstName" }
        let(:employee_params) { { first_name: first_name } }

        run_test! do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          attributes = json_response["data"]["attributes"]
          expect(attributes["first_name"]).to eq("OnlyFirstName")
          expect(attributes["last_name"]).to eq("Name") # unchanged
        end
      end

      response "404", "Employee not found for update" do
        let(:user) { create(:user, email_address: "john10@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { 99999 }
        let(:employee_params) { { first_name: "DoesNotMatter" } }

        run_test! do
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("error")
          expect(json_response["error"]).to eq("Employee not found")
        end
      end

      response "422", "Validation error - invalid email format" do
        let(:user) { create(:user, email_address: "john11@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }
        let(:employee) { create(:employee, email_address: "valid.employee@example.com", first_name: "Valid", last_name: "Employee") }
        let(:id) { employee.id }
        let(:email_address) { "invalid-email" }
        let(:employee_params) { { email_address: email_address } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("error")
          expect(json_response["error"]).to include("Email address is not a valid email address")
        end
      end

      response "422", "Validation error - duplicate email address" do
        let(:user) { create(:user, email_address: "john12@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }
        let!(:existing_employee) { create(:employee, email_address: "existing@example.com") }
        let!(:employee) { create(:employee, email_address: "to.update@example.com", first_name: "ToUpdate", last_name: "Employee") }
        let(:id) { employee.id }
        let(:email_address) { "existing@example.com" }
        let(:employee_params) { { email_address: email_address } }

        run_test! do
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("error")
          expect(json_response["error"]).to include("Email address has already been taken")
        end
      end

      response "401", "Unauthorized - missing token" do
        let(:employee) { create(:employee) }
        let(:id) { employee.id }
        let(:Authorization) { "" }
        let(:employee_params) { { first_name: "DoesNotMatter" } }

        run_test! do
          expect([ 401, 403 ]).to include(response.status)
        end
      end

      response "401", "Unauthorized - invalid token" do
        let(:employee) { create(:employee) }
        let(:id) { employee.id }
        let(:Authorization) { "Bearer invalid_token_here" }
        let(:employee_params) { { first_name: "DoesNotMatter" } }

        run_test! do
          expect([ 401, 403 ]).to include(response.status)
        end
      end
    end

    delete "Deletes an existing employee" do
      tags "Employees"
      consumes "application/json"
      produces "application/json"
      security [ Bearer: [] ]

      parameter name: :Authorization, in: :header, type: :string, required: true, description: "Bearer token"

      response "200", "Employee deleted successfully" do
        let(:user) { create(:user, email_address: "john13@example.com", password: "password123") }
        let(:session_record) { create(:session, user: user) }
        let(:token) { session_record.token }
        let(:Authorization) { "Bearer #{token}" }
        let(:employee) { create(:employee, email_address: "to.delete@example.com", first_name: "ToDelete", last_name: "Employee") }
        let(:id) { employee.id }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("message")
          expect(json_response["message"]).to eq("Employee deleted successfully")

          # Verify employee was actually deleted from database
          expect { Employee.find(employee.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      response "404", "Employee not found for deletion" do
        let(:user) { create(:user, email_address: "john14@example.com", password: "password123") }
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
