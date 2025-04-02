# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  include Authentication
  include PaymentAccess
  include UserRole
  helper_method :current_user

  # ROLE-CHECK METHODS
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

  helper_method :teacher?, :admin?, :student?, :owner?, :unassigned?

  protect_from_forgery with: :exception
end
