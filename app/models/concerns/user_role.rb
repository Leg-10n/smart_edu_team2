module UserRole
  extend ActiveSupport::Concern

  ROLES = %w[admin owner teacher student unassigned].freeze
end
