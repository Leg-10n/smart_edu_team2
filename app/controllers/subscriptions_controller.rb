class SubscriptionsController < ApplicationController
  before_action :require_authentication
  before_action :set_subscription, only: [:show, :cancel]

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
      # Create or update customer with card token
      token = params[:omise_token]
      if token.blank?
        redirect_to new_subscription_path, alert: "No card token received. Please try again."
        return
      end

      # Create or update customer
      customer = current_user.create_or_update_omise_customer(token)

      # Start a transaction
      ActiveRecord::Base.transaction do
        # Create subscription record
        @subscription = current_user.subscriptions.build(subscription_params)
        @subscription.status = 'pending'
        @subscription.started_at = Time.current

        # Set expiration date based on plan
        plan_details = Subscription::PLANS[@subscription.plan_name]
        if plan_details[:interval] == 'month'
          @subscription.expires_at = 1.month.from_now
        elsif plan_details[:interval] == 'year'
          @subscription.expires_at = 1.year.from_now
        end

        if @subscription.save
          # Create charge
          charge = Omise::Charge.create(
            amount: plan_details[:amount],
            currency: "thb",
            customer: customer.id,
            description: "Subscription: #{plan_details[:name]}"
          )

          # Create payment record
          payment = @subscription.payments.build(
            user: current_user,
            amount: charge.amount / 100.0, # Convert to decimal (bahts)
            status: charge.status,
            omise_charge_id: charge.id,
            paid_at: charge.paid_at
          )
          payment.save!

          # Update user subscription status
          if charge.status == 'successful'
            current_user.update(
              subscription_status: 'active',
              subscription_end_date: @subscription.expires_at
            )
            @subscription.update(status: 'active')

            redirect_to dashboard_path, notice: "Subscription created successfully!"
          else
            @subscription.update(status: 'failed')
            redirect_to new_subscription_path, alert: "Payment was not successful. Please try again."
          end
        else
          render :new, status: :unprocessable_entity
        end
      end
    rescue Omise::Error => e
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

      @subscription.update(status: 'cancelled')
      current_user.update(subscription_status: 'cancelled')

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