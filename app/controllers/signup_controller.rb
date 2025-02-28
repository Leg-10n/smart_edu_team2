class SignupController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if params[:is_signup] == "true"
        start_new_session_for @user
        redirect_to after_authentication_url
      else
        notice: "User was successfully created by the admin."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
