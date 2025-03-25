# app/services/subscription_service.rb
class SubscriptionService
  GRACE_PERIOD_DAYS = 30

  def self.create_subscription(user, token, plan, amount)
    begin
      # Create charge with Omise
      charge = Omise::Charge.create(
        amount: amount,
        currency: "thb",
        card: token,
        customer: user.omise_customer_id,
        description: "Subscription to #{plan} plan"
      )

      # Create subscription record
      subscription = user.subscriptions.create!(
        status: charge.paid ? "active" : "pending",
        plan_name: plan,
        started_at: Time.current,
        expires_at: 1.month.from_now,
        omise_charge_id: charge.id
      )

      # Create payment record
      user.payments.create!(
        subscription: subscription,
        amount: amount,
        status: charge.paid ? "successful" : "failed",
        omise_charge_id: charge.id,
        paid_at: charge.paid ? Time.current : nil
      )

      # Update user's subscription status if payment successful
      if charge.paid
        activate_user(user, subscription.expires_at)
      end

      subscription
    rescue Omise::Error => e
      Rails.logger.error "Omise payment error: #{e.message}"
      nil
    end
  end

  def self.activate_subscription(subscription_or_user, end_date = nil)
    if subscription_or_user.is_a?(User)
      activate_user(subscription_or_user, end_date || 1.month.from_now)
    else
      subscription = subscription_or_user
      subscription.update(
        status: "active",
        expires_at: end_date || 1.month.from_now
      )

      # Also update the user's subscription status
      activate_user(subscription.user, subscription.expires_at)
    end
  end

  def self.activate_user(user, end_date)
    user.update(
      subscription_status: "active",
      subscription_end_date: end_date
    )
  end

  def self.enter_grace_period(subscription)
    grace_end_date = Time.current + GRACE_PERIOD_DAYS.days
    subscription.update(
      status: "grace",
      expires_at: grace_end_date
    )

    # Update user status
    subscription.user.update(
      subscription_status: "grace",
      subscription_end_date: grace_end_date
    )

    # Send notification email
    # UserMailer.subscription_entered_grace_period(subscription.user).deliver_later
  end

  def self.deactivate_subscription(subscription)
    subscription.update(
      status: "expired"
    )

    # Update user status
    subscription.user.update(
      subscription_status: "free",
      subscription_end_date: nil
    )

    # Send notification email
    # UserMailer.subscription_expired(subscription.user).deliver_later
  end

  def self.process_subscription_renewal(subscription)
    # Update the subscription end date
    new_end_date = subscription.expires_at + 1.month
    subscription.update(expires_at: new_end_date, status: "active")

    # Update user's subscription status
    activate_user(subscription.user, new_end_date)

    # Send renewal confirmation
    # UserMailer.subscription_renewed(subscription.user).deliver_later
  end

  def self.process_subscription_cancellation(subscription)
    # Update subscription status
    subscription.update(status: "canceled")

    # Keep the user's access until the current period ends
    # We don't update user.subscription_status here to let them use
    # the service until the expiration date

    # Send cancellation confirmation
    # UserMailer.subscription_canceled(subscription.user).deliver_later
  end

  def self.check_for_expired_subscriptions
    # Find active subscriptions that have expired
    expired_active = Subscription.where(
      status: "active",
      expires_at: ..Time.current
    )

    expired_active.each do |subscription|
      # Move to grace period
      enter_grace_period(subscription)
      Rails.logger.info "Subscription #{subscription.id} has expired and entered grace period for user #{subscription.user.id}"
    end

    # Find grace period subscriptions that have expired
    expired_grace = Subscription.where(
      status: "grace",
      expires_at: ..Time.current
    )

    expired_grace.each do |subscription|
      # Grace period expired
      deactivate_subscription(subscription)
      Rails.logger.info "Subscription #{subscription.id} grace period has expired for user #{subscription.user.id}"
    end
  end

  def self.extend_subscription(subscription, days)
    return false unless subscription && days.to_i > 0

    new_expiry = subscription.expires_at + days.to_i.days
    subscription.update(
      expires_at: new_expiry,
      status: "active" # Ensure status is active when extending
    )

    # Update user's subscription status
    activate_user(subscription.user, new_expiry)

    # Log the extension
    Rails.logger.info "Extended subscription #{subscription.id} by #{days} days for user #{subscription.user.id}"

    true
  end

  def self.reactivate_canceled_subscription(subscription)
    return false unless subscription && subscription.status == "canceled"

    # Set new expiration date
    new_expiry = Time.current + 1.month

    subscription.update(
      status: "active",
      expires_at: new_expiry
    )

    # Update user's subscription status
    activate_user(subscription.user, new_expiry)

    # Log the reactivation
    Rails.logger.info "Reactivated subscription #{subscription.id} for user #{subscription.user.id}"

    true
  end

  def self.handle_failed_payment(subscription)
    # Put subscription in grace period
    enter_grace_period(subscription)

    # Log the failure
    Rails.logger.warn "Payment failed for subscription #{subscription.id}, entering grace period"

    # Send notification to user
    # UserMailer.payment_failed(subscription.user).deliver_later
  end

  def self.get_subscription_status_summary
    {
      active: Subscription.where(status: "active").count,
      grace: Subscription.where(status: "grace").count,
      expired: Subscription.where(status: "expired").count,
      canceled: Subscription.where(status: "canceled").count,
      total: Subscription.count
    }
  end
end
