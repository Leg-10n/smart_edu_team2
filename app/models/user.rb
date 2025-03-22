# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  first_name      :string
#  is_active       :boolean          default(TRUE)
#  last_name       :string
#  password_digest :string           not null
#  role            :string           default("unassigned")
#  uuid            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_uuid           (uuid) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  ROLES = %w[admin teacher student unassigned].freeze

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 }, if: :password_required?
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :uuid, presence: true, uniqueness: true

  before_validation :generate_uuid, on: :create

  after_initialize do
    self.role ||= "unassigned" if new_record?
  end

  private

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def password_required?
    new_record? || password.present?
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id first_name last_name email created_at updated_at]
  end
end
