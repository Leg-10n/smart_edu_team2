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
    redirect_to root_path, alert: "You must have role [ teacher ] to access the requested page." unless teacher?
  end

  def require_admin
    redirect_to root_path, alert: "You must have role [ admin ] to access the requested page." unless admin?
  end

  def require_student
    redirect_to root_path, alert: "You must have role [ student ] to access the requested page." unless student?
  end
end
