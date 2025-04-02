class SubscriptionsController < ApplicationController
  before_action :require_authentication
  before_action :set_subscription, only: [ :show, :cancel ]

  def index
    @subscriptions = current_user.subscriptions.order(created_at: :desc)
  end

  def new
    redirect_to dashboard_path, notice: "You already have an active subscription" if current_user.has_valid_subscription?
    @subscription = Subscription.new
  end

  def create
    # Set Omise API keys
    Omise.api_key = Rails.application.credentials.dig(:omise, :secret_key)

    begin
      # Get the token
      token = params[:omise_token]
      Rails.logger.info "Received token: #{token}"

      if token.blank?
        redirect_to new_subscription_path, alert: "No card token received. Please try again."
        nil
      end

      # Rest of your method remains the same...
    rescue => e
      Rails.logger.error "Omise error: #{e.message}"
      redirect_to new_subscription_path, alert: "Error: #{e.message}"
    end
  end

  def show
  end

  def cancel
    begin
      Omise.api_key = Rails.application.credentials.dig(:omise, :secret_key)

      if @subscription.omise_subscription_id.present?
        omise_subscription = Omise::Subscription.retrieve(@subscription.omise_subscription_id)
        omise_subscription.cancel
      end

      @subscription.update(status: "cancelled")
      current_user.update(subscription_status: "cancelled")

      redirect_to subscriptions_path, notice: "Subscription cancelled successfully."
    rescue Omise::Error => e
      redirect_to subscription_path(@subscription), alert: "Error cancelling subscription: #{e.message}"
    end
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:plan_name)
  end
end
