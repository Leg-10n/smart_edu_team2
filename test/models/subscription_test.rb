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
require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
