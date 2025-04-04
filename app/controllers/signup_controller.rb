class SignupController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    # using transaction because now we want to
    # save either both school and owner or none at all and rollback
    transaction_succeed = false
    ActiveRecord::Base.transaction do
      # school = School.new(school_name_params)
      # school.save!
      school = School.create!(school_name_params)
      @user = User.new(user_params)
      @user.school_id = school.id
      @user.role = "owner"
      @user.save!
      transaction_succeed = true
    end
    if transaction_succeed
      session[:user_id] = @user.id  # Ensure the session is set
      start_new_session_for @user
      redirect_to after_authentication_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :first_name, :last_name)
  end
  def school_name_params
    params.require(:user).permit(:school_name)
  end
end
