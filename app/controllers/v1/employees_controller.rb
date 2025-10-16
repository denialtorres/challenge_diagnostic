class V1::EmployeesController < ApplicationController
  def index
    employees = Employee.all
    render json: employees.as_json(
      only: [ :id, :email_address, :first_name, :last_name, :phone_number, :created_at, :updated_at ],
      methods: [ :type ]
    )
  end
end
