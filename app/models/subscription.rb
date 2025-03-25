# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  expires_at            :datetime
#  plan_name             :string
#  started_at            :datetime
#  status                :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  omise_subscription_id :string
#  user_id               :integer          not null
#
# Indexes
#
#  index_subscriptions_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
# app/models/subscription.rb
class Subscription < ApplicationRecord
  belongs_to :user
  has_many :payments, dependent: :destroy

  scope :active, -> { where(status: "active") }
  scope :in_grace_period, -> { where(status: "grace") }

  def active?
    status == "active" && expires_at > Time.current
  end

  def in_grace_period?
    status == "grace" && expires_at > Time.current
  end

  def expired?
    expires_at <= Time.current
  end

  def days_remaining
    return 0 if expired?
    ((expires_at - Time.current) / 1.day).ceil
  end

  def extends_by_days(days)
    update(expires_at: expires_at + days.days)

    # Also update user's subscription end date
    user.update(subscription_end_date: expires_at)
  end
end