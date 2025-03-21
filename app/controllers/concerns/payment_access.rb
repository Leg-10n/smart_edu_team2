# app/controllers/concerns/payment_access.rb
module PaymentAccess
  extend ActiveSupport::Concern

  # Check if user has active subscription
  def require_paid_subscription
    # First ensure the user is authenticated
    require_authentication
    return unless authenticated?

    # Now we can safely check subscription status
    return if current_user_has_active_subscription?

    # Allow access during grace period
    if current_user_in_grace_period?
      flash.now[:alert] = "Your subscription has expired. You have #{days_left_in_grace_period} days left in your grace period. Please renew your subscription."
      return
    end

    redirect_to new_payment_path, alert: "This feature requires an active subscription."
  end

  # Check if user has valid subscription or is in grace period
  def require_valid_access
    require_authentication
    return unless authenticated?

    return if current_user_has_active_subscription? || current_user_in_grace_period?

    redirect_to new_payment_path, alert: "Your access has expired. Please subscribe to continue using all features."
  end

  private

  def current_user_has_active_subscription?
    return false unless authenticated?  # Safety check

    Current.user.subscription_status == "active" &&
      (Current.user.subscription_end_date.nil? || Current.user.subscription_end_date > Time.now)
  end

  def current_user_in_grace_period?
    return false unless authenticated?  # Safety check

    Current.user.subscription_status == "grace" &&
      Current.user.subscription_end_date &&
      Current.user.subscription_end_date > Time.now
  end

  def days_left_in_grace_period
    return 0 unless authenticated? && Current.user.subscription_end_date

    ((Current.user.subscription_end_date - Time.now) / 1.day).ceil
  end
end
