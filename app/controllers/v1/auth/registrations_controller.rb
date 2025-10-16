class V1::Auth::RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[create]

  def create
    employee = Employee.new(employee_params)

    if employee.save
      start_new_session_for(employee)
      render json: {
        token: Current.session.token,
        employee: employee.as_json.merge('type' => employee.type)
      }, status: :created
    else
      render json: { error: employee.errors.full_messages }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique => e
    render json: { error: [ "There was a problem creating your account" ] }, status: :unprocessable_content
  end

  private

  def employee_params
    params.permit(:email_address, :password, :password_confirmation,
                  :first_name, :last_name, :date_of_birth, :phone_number,
                  :international_code)
  end
end
