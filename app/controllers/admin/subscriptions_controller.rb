# app/controllers/admin/subscriptions_controller.rb
class Admin::SubscriptionsController < ApplicationController
  include Authentication

  before_action :require_admin

  def index
    @subscriptions = Subscription.includes(:user).order(created_at: :desc).page(params[:page]).per(20)
  end

  def show
    @subscription = Subscription.find(params[:id])
    @payments = @subscription.payments.order(created_at: :desc)
  end

  def extend
    @subscription = Subscription.find(params[:id])
    extension_days = params[:days].to_i

    if extension_days > 0
      new_expiry = @subscription.expires_at + extension_days.days
      @subscription.update(expires_at: new_expiry)

      # Update user's subscription status and end date
      SubscriptionService.activate_subscription(@subscription.user, new_expiry)

      redirect_to admin_subscription_path(@subscription), notice: "Subscription extended by #{extension_days} days."
    else
      redirect_to admin_subscription_path(@subscription), alert: "Invalid extension period."
    end
  end

  private

  def require_admin
    # Implement your admin check here
    # Example:
    redirect_to root_path, alert: "Access denied." unless Current.user&.admin?
  end
end
