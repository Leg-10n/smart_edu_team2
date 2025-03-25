# app/jobs/check_subscription_status_job.rb
class CheckSubscriptionStatusJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting subscription status check at #{Time.current}"
    check_count = { expired_active: 0, expired_grace: 0 }

    # Process active subscriptions that have expired
    expired_active = Subscription.where(
      status: "active",
      expires_at: (Time.at(0)..Time.current)
    )

    expired_active.find_each do |subscription|
      begin
        SubscriptionService.enter_grace_period(subscription)
        check_count[:expired_active] += 1
        Rails.logger.info "Moved subscription #{subscription.id} (user: #{subscription.user_id}) to grace period"
      rescue => e
        Rails.logger.error "Error moving subscription #{subscription.id} to grace period: #{e.message}"
      end
    end

    # Process grace period subscriptions that have expired
    expired_grace = Subscription.where(
      status: "grace",
      expires_at: (Time.at(0)..Time.current)
    )

    expired_grace.find_each do |subscription|
      begin
        SubscriptionService.deactivate_subscription(subscription)
        check_count[:expired_grace] += 1
        Rails.logger.info "Expired subscription #{subscription.id} (user: #{subscription.user_id}) after grace period"
      rescue => e
        Rails.logger.error "Error deactivating subscription #{subscription.id}: #{e.message}"
      end
    end

    # Check for inconsistencies between user and subscription statuses
    check_status_consistency

    Rails.logger.info "Completed subscription check: #{check_count[:expired_active]} moved to grace, #{check_count[:expired_grace]} deactivated"
  end

  private

  def check_status_consistency
    # Find users with active status but no active subscription
    inconsistent_users = User.where(subscription_status: "active")
                             .joins("LEFT JOIN subscriptions ON subscriptions.user_id = users.id AND subscriptions.status = 'active'")
                             .where("subscriptions.id IS NULL")

    inconsistent_users.find_each do |user|
      begin
        # Update user to free status if they have no active subscription
        user.update(subscription_status: "free", subscription_end_date: nil)
        Rails.logger.warn "Fixed inconsistent user status for user #{user.id}: changed from 'active' to 'free'"
      rescue => e
        Rails.logger.error "Error fixing user status for user #{user.id}: #{e.message}"
      end
    end

    # Find users with grace status but no in-grace subscription
    inconsistent_grace_users = User.where(subscription_status: "grace")
                                   .joins("LEFT JOIN subscriptions ON subscriptions.user_id = users.id AND subscriptions.status = 'grace'")
                                   .where("subscriptions.id IS NULL")

    inconsistent_grace_users.find_each do |user|
      begin
        # Update user to free status if they have no grace period subscription
        user.update(subscription_status: "free", subscription_end_date: nil)
        Rails.logger.warn "Fixed inconsistent user status for user #{user.id}: changed from 'grace' to 'free'"
      rescue => e
        Rails.logger.error "Error fixing grace status for user #{user.id}: #{e.message}"
      end
    end
  end
end