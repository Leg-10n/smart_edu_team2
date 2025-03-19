# == Schema Information
#
# Table name: payments
#
#  id              :integer          not null, primary key
#  amount          :decimal(, )
#  paid_at         :datetime
#  status          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  omise_charge_id :string
#  subscription_id :integer          not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_payments_on_subscription_id  (subscription_id)
#  index_payments_on_user_id          (user_id)
#
# Foreign Keys
#
#  subscription_id  (subscription_id => subscriptions.id)
#  user_id          (user_id => users.id)
#
# app/models/payment.rb
class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :subscription, optional: true

  scope :successful, -> { where(status: "successful") }
end