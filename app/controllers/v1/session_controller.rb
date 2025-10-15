class V1::SessionController < ApplicationController
  allow_unauthenticated_access only: [:create]

  def create
    if user = User.authenticate_by(session_params)
      start_new_session_for(user)
      render json: { token: Current.session.token }
    else
      render json: { error: "Invalid email address or password" }, status: :unauthorized
    end
  end

  private

  def session_params
    params.permit(:email_address, :password)
  end
end
