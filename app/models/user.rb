# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  discarded_at          :datetime
#  email_address         :string           not null
#  first_name            :string
#  last_name             :string
#  password_digest       :string           not null
#  role                  :string           default("unassigned")
#  subscription_end_date :datetime
#  subscription_status   :string           default("free")
#  uuid                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  omise_customer_id     :string
#  school_id             :integer
#
# Indexes
#
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
  has_many :subscriptions, dependent: :destroy
  has_many :payments, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 }, if: :password_required?
  validates :role, presence: true, inclusion: { in: UserRole::ROLES }
  validates :uuid, presence: true, uniqueness: true

  before_validation :set_default_uuid, if: -> { uuid.blank? }
  before_validation :set_default_subscription_status, if: -> { subscription_status.blank? }

  after_initialize do
    self.role ||= "unassigned" if new_record?
  end

  def has_valid_subscription?
    subscription_status == "active" && (subscription_end_date.nil? || subscription_end_date > Time.current)
  end

  def create_or_update_omise_customer(token)
    if omise_customer_id.blank?
      # Create a new customer
      customer = Omise::Customer.create(
        email: email_address,
        description: "User #{id} - #{email_address}",
        card: token
      )
      update(omise_customer_id: customer.id)
      customer
    else
      # Update existing customer with new card
      customer = Omise::Customer.retrieve(omise_customer_id)
      customer.update(card: token)
      customer
    end
  end

  private

  def set_default_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def set_default_subscription_status
    self.subscription_status = "free"
  end

  def password_required?
    new_record? || password.present?
  end
end
