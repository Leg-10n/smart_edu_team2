# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  discarded_at    :datetime
#  email_address   :string           not null
#  first_name      :string
#  is_active       :boolean          default(TRUE)
#  last_name       :string
#  password_digest :string           not null
#  role            :string           default("unassigned")
#  uuid            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_id       :integer
#
# Indexes
#
#  index_users_on_discarded_at   (discarded_at)
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_school_id      (school_id)
#  index_users_on_uuid           (uuid) UNIQUE
#
# Foreign Keys
#
#  school_id  (school_id => schools.id)
#
class User < ApplicationRecord
  include UserRole

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 }, if: :password_required?
  validates :role, presence: true, inclusion: { in: UserRole::ROLES }
  validates :uuid, presence: true, uniqueness: true

  before_validation :set_default_uuid, if: -> { uuid.blank? }

  after_initialize do
    self.role ||= "unassigned" if new_record?
  end

  private

  def set_default_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def password_required?
    new_record? || password.present?
  end
end
