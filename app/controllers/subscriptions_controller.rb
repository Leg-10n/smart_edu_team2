# app/controllers/subscriptions_controller.rb
class SubscriptionsController < ApplicationController
  include Authentication

  before_action :authenticate_user

  def index
    @subscriptions = Current.user.subscriptions.order(created_at: :desc)
  end

  def show
    @subscription = Current.user.subscriptions.find(params[:id])
  end

  def new
    redirect_to subscriptions_path, notice: "You already have an active subscription" if Current.user.subscribed?
  end

  def create
    # Handle subscription creation - this is mainly handled in the payments controller
    redirect_to new_payment_path
  end

  def cancel
    @subscription = Current.user.subscriptions.find(params[:id])

    if @subscription.active?
      begin
        OmiseService.cancel_subscription(@subscription.omise_subscription_id)
        @subscription.update(status: "canceled")
        redirect_to subscriptions_path, notice: "Your subscription has been canceled"
      rescue => e
        redirect_to subscriptions_path, alert: "Failed to cancel subscription: #{e.message}"
      end
    else
      redirect_to subscriptions_path, alert: "This subscription is not active"
    end
  end
end
