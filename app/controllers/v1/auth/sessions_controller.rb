class V1::Auth::SessionsController < ApplicationController
  allow_unauthenticated_access only: [ :create ]

  def create
    return render json: { error: "Invalid email address or password" }, status: :unauthorized if session_params[:email_address].blank? || session_params[:password].blank?

    if user = User.authenticate_by(session_params)
      start_new_session_for(user)
      render json: { token: Current.session.token }
    else
      render json: { error: "Invalid email address or password" }, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    render json: { message: "Logged out" }, status: :ok
  end

  private

  def session_params
    params.permit(:email_address, :password)
  end
end
