class V1::EmployeesController < ApplicationController
  def index
    employees = Employee.all
    render json: employees.as_json(
      only: [ :id, :email_address, :first_name, :last_name, :phone_number, :created_at, :updated_at ],
      methods: [ :type ]
    )
  end

  def show
    employee = Employee.find(params[:id])
    render json: employee.as_json(
      only: [ :id, :email_address, :first_name, :last_name, :phone_number, :created_at, :updated_at ],
      methods: [ :type ]
    )
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Employee not found" }, status: :not_found
  end

  def create
    employee = Employee.new(employee_params)

    if employee.save
      render json: employee.as_json(
        only: [ :id, :email_address, :first_name, :last_name, :phone_number, :created_at, :updated_at ],
        methods: [ :type ]
      ), status: :created
    else
      render json: { error: employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def employee_params
    params.permit(:email_address, :password, :password_confirmation, :first_name, :last_name,
                  :date_of_birth, :phone_number, :international_code)
  end
end
