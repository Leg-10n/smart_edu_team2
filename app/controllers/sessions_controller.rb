# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  # Let visitors see login form & process creation without being logged in
  allow_unauthenticated_access only: [ :new, :create ]

  def new
    # Renders login form
  end

  def create
    permitted = params.permit(:email_address, :password)
    user = User.authenticate_by(permitted)  # Or however you actually authenticate
    if user
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: "Logged in successfully."
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "You have been logged out."
  end
end
