class V1::EmployeesController < ApplicationController
  def index
    employees = Employee.all

    page = if params[:page_token].present?
             Rotulus::Page.new(employees, limit: 10).at(params[:page_token])
    else
             Rotulus::Page.new(employees, limit: 10)
    end

    render json: PaginatedEmployeesSerializer.new(page).serializable_hash
  end

  def show
    employee = Employee.find(params[:id])
    render json: EmployeeSerializer.new(employee).serializable_hash
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Employee not found" }, status: :not_found
  end

  def create
    employee = Employee.new(employee_params)

    if employee.save
      render json: EmployeeSerializer.new(employee).serializable_hash, status: :created
    else
      render json: { error: employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    employee = Employee.find(params[:id])

    if employee.update(employee_params)
      render json: EmployeeSerializer.new(employee).serializable_hash, status: :ok
    else
      render json: { error: employee.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Employee not found" }, status: :not_found
  end

  def destroy
    employee = Employee.find(params[:id])
    employee.destroy
    render json: { message: "Employee deleted successfully" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Employee not found" }, status: :not_found
  end

  private

  def employee_params
    params.permit(:email_address, :password, :password_confirmation, :first_name, :last_name,
                  :date_of_birth, :phone_number, :international_code, :page_token)
  end
end
