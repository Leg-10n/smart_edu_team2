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
      # Debug all parameters
      Rails.logger.debug "All parameters: #{params.to_unsafe_h.inspect}"

      # Get the token - check both possible parameter names
      token = params[:omise_token] || params[:omiseToken]
      plan_name = params[:plan_name]

      Rails.logger.debug "Extracted token: #{token.present? ? 'Present' : 'Missing'}"
      Rails.logger.debug "Plan name: #{plan_name}"

      if token.blank?
        return redirect_to new_subscription_path, alert: "No card token received. Please try again."
      end

      # Create or update Omise customer with the new card
      customer = current_user.create_or_update_omise_customer(token)

      # Get plan details
      plan = Subscription::PLANS[plan_name]
      raise "Invalid plan selected" unless plan

      # Instead of creating a subscription, create a charge
      charge = Omise::Charge.create({
                                      amount: plan[:amount],
                                      currency: "thb",
                                      customer: customer.id,
                                      description: "#{plan[:name]} subscription payment"
                                    })

      if charge.paid
        # Calculate expiry date based on interval
        expires_at = Time.current + (plan[:interval] == "month" ? 1.month : 1.year)

        # Create subscription record in our database
        subscription = current_user.subscriptions.create!(
          plan_name: plan_name,
          status: "active",
          started_at: Time.current,
          expires_at: expires_at
        )

        # Create payment record
        subscription.payments.create!(
          amount: plan[:amount] / 100.0,
          user_id: current_user.id,
          status: "successful",
          omise_charge_id: charge.id,
          paid_at: Time.current
        )

        # Update user subscription status
        current_user.update(
          subscription_status: "active",
          subscription_end_date: expires_at
        )

        redirect_to subscription_path(subscription), notice: "Payment successful! Your subscription is now active."
      else
        redirect_to new_subscription_path, alert: "Payment failed: #{charge.failure_message}"
      end

    rescue Omise::Error => e
      # Log the error details for debugging
      Rails.logger.error "Omise error: #{e.message}"
      redirect_to new_subscription_path, alert: "Payment error: #{e.message}"
    rescue => e
      # Log general errors
      Rails.logger.error "Subscription error: #{e.message}"
      Rails.logger.error "Error backtrace: #{e.backtrace.join("\n")}"
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
