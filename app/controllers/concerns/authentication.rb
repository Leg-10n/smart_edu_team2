# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user
  end

  class_methods do
    # Example usage in a controller:
    #   allow_unauthenticated_access only: [:landing, :some_other_public_action]
    #
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    current_user.present?
  end

  def require_authentication
    authenticated? || request_authentication
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path, alert: "Please log in first."
  end

  def current_user
    # Return memoized @current_user if set, else find or nil
    @current_user ||= begin
                        # If we have a conventional Rails session user_id set
                        if session[:user_id]
                          User.find_by(id: session[:user_id])
                        else
                          nil
                        end
                      end
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || "/dashboard"
  end

  # Called once a user is confirmed. In your SessionsController#create for example.
  def start_new_session_for(user)
    reset_session  # Protect from fixation attacks
    session[:user_id] = user.id
  end

  def terminate_session
    reset_session
  end
end
