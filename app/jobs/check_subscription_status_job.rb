# app/jobs/check_subscription_status_job.rb
class CheckSubscriptionStatusJob < ApplicationJob
  queue_as :default

  def perform
    # Find subscriptions that have expired
    expired_subscriptions = Subscription.where(
      "status IN (?) AND expires_at <= ?",
      [ "active", "grace" ],
      Time.now
    )

    expired_subscriptions.each do |subscription|
      if subscription.status == "active"
        # Move to grace period
        subscription.update(status: "grace", expires_at: Time.now + 30.days)
        Rails.logger.info "Subscription #{subscription.id} has expired and entered grace period"
      else
        # Grace period expired
        subscription.update(status: "expired")
        Rails.logger.info "Subscription #{subscription.id} grace period has expired"
      end
    end
  end
end
