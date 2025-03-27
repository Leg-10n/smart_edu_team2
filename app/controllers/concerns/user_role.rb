# app/controllers/concerns/user_role.rb
module UserRole
  extend ActiveSupport::Concern

  included do
    # Example: enforce a recognized list of roles if needed
    ROLES = %w[admin teacher student unassigned].freeze

    # Add other role checks or logic if desired
  end

  private

  def require_teacher
    redirect_to root_path, alert: "Only teachers can do that." unless teacher?
  end

  def require_admin
    redirect_to root_path, alert: "Only admins can do that." unless admin?
  end

  def require_student
    redirect_to root_path, alert: "Only students can do that." unless student?
  end
end
