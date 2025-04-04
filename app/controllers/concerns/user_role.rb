# app/controllers/concerns/user_role.rb
module UserRole
  extend ActiveSupport::Concern

  included do
    # Define the constant only if it's not already defined
    unless defined?(ROLES)
      ROLES = %w[admin owner teacher student unassigned].freeze
    end
  end

  def require_teacher
    unless teacher?
      redirect_to root_path, alert: "You must have role [ teacher ] to access the requested page."
    end
  end

  def require_admin
    unless admin?
      redirect_to root_path, alert: "You must have role [ admin ] to access the requested page."
    end
  end

  def require_student
    unless student?
      redirect_to root_path, alert: "You must have role [ student ] to access the requested page."
    end
  end

  def require_owner
    unless owner?
      redirect_to root_path, alert: "You must have role [ owner ] to access the requested page."
    end
  end

  def require_unassigned
    unless unassigned?
      redirect_to root_path, alert: "You must have role [ unassigned ] to access the requested page."
    end
  end

  def require_admin_or_owner
    unless admin? || owner?
      redirect_to root_path, alert: "You must have role [ owner or admin ] to access the requested page."
    end
  end
end
