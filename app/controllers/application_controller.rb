class ApplicationController < ActionController::Base
  include Authentication
  include UserRole
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  helper_method :current_user  # Make it accessible in views
  # check the user's role

  def require_role(role)
    unless current_user&.role == role
      flash[:alert] = "You must have role [ #{role} ] to access the requested page."
      redirect_to root_path
    end
  end

  UserRole::ROLES.each do |role|
    define_method("require_#{role}") { require_role(role) }
    define_method("#{role}?") { current_user&.role == role }
  end

  helper_method(*UserRole::ROLES.map { |role| "#{role}?" })
end
