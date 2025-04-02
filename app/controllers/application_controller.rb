# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  include Authentication
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

  before_action :check_subscription

  private

  def check_subscription
    # Skip for unauthenticated users and for subscription management pages
    return unless authenticated?
    return if controller_name == 'subscriptions' || controller_name == 'sessions' ||
      (controller_name == 'home' && action_name == 'landing')

    # Check if user has an active subscription
    unless current_user.has_valid_subscription?
      redirect_to new_subscription_path, alert: "Please subscribe to access this feature."
    end
  end
end