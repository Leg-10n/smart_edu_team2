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
class Subscription < ApplicationRecord
  belongs_to :user
  has_many :payments, dependent: :destroy

  validates :plan_name, presence: true
  validates :status, presence: true

  PLANS = {
    'basic_monthly' => { name: 'Basic Monthly', amount: 10000, interval: 'month' },
    'premium_monthly' => { name: 'Premium Monthly', amount: 25000, interval: 'month' },
    'basic_yearly' => { name: 'Basic Yearly', amount: 100000, interval: 'year' },
    'premium_yearly' => { name: 'Premium Yearly', amount: 250000, interval: 'year' }
  }.freeze

  def active?
    status == 'active' && (expires_at.nil? || expires_at > Time.current)
  end

  def amount_in_thb
    PLANS[plan_name][:amount] / 100.0
  end
end
