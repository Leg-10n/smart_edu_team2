# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  include Authentication
  include UserRole
  # ^ This is your authentication concern that sets up current_user and require_authentication

  # ----------------------------------------------------------------
  # ROLE-CHECK METHODS
  # ----------------------------------------------------------------
  # Because your layout calls <%= if teacher? %>, we define them here as instance
  # methods. We also declare them as helper_method, so they are callable in views.

  def teacher?
    current_user&.role == "teacher"
  end

  def admin?
    current_user&.role == "admin"
  end

  def student?
    current_user&.role == "student"
  end

  def owner?
    current_user&.role == "owner"
  end

  def unassigned?
    current_user&.role == "unassigned"
  end

  # Make them available to the views:
  helper_method :teacher?, :admin?, :student?, :owner?, :unassigned?

  protect_from_forgery with: :exception
end
