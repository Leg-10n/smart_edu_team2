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
        customer: user.omise_customer.id,
        description: "Subscription to #{plan} plan"
      )

      # Create subscription record
      subscription = user.subscriptions.create!(
        status: charge.paid ? "active" : "pending",
        plan: plan,
        amount: amount,
        expires_at: 1.month.from_now,
        omise_charge_id: charge.id
      )

      # Create payment record
      user.payments.create!(
        subscription: subscription,
        amount: amount,
        status: charge.paid ? "completed" : "failed",
        payment_method: "credit_card",
        omise_charge_id: charge.id
      )

      subscription
    rescue Omise::Error => e
      Rails.logger.error "Omise payment error: #{e.message}"
      nil
    end
  end

  def self.activate_subscription(subscription)
    subscription.update(
      status: "active",
      expires_at: 1.month.from_now
    )
  end

  def self.enter_grace_period(subscription)
    subscription.update(
      status: "grace",
      expires_at: Time.now + GRACE_PERIOD_DAYS.days
    )
  end

  def self.deactivate_subscription(subscription)
    subscription.update(
      status: "expired"
    )
  end

  def self.process_subscription_renewal(subscription)
    # Update the subscription end date
    new_end_date = subscription.expires_at + 1.month
    subscription.update(expires_at: new_end_date, status: "active")
  end

  def self.process_subscription_cancellation(subscription)
    # Update subscription status
    subscription.update(status: "canceled")
  end

  def self.check_for_expired_subscriptions
    # Find subscriptions that have expired
    expired_subscriptions = Subscription.where(
      "status IN (?) AND expires_at <= ?",
      [ "active", "grace" ],
      Time.now
    )

    expired_subscriptions.each do |subscription|
      if subscription.status == "active"
        # Move to grace period
        enter_grace_period(subscription)
      else
        # Grace period expired
        deactivate_subscription(subscription)
      end
    end
  end
end
