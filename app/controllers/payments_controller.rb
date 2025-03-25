# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  include Authentication

  before_action :require_authentication, except: [:success, :failure, :webhook]
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def new
    # Redirect if already subscribed
    redirect_to root_path, notice: "You're already subscribed!" if Current.user&.subscribed?
  end

  def create
    # Get the token from the form
    token = params[:omise_token]
    plan = params[:plan]

    if token.blank?
      redirect_to new_payment_path, alert: "Missing card information"
      return
    end

    # Process using Omise
    begin
      # Create or retrieve a customer
      customer = find_or_create_customer(token)

      # Store the customer ID with the user
      Current.user.update(omise_customer_id: customer.id) unless Current.user.omise_customer_id.present?

      # Charge amount based on plan
      amount = get_plan_amount_for(plan)

      charge = Omise::Charge.create(
        amount: (amount * 100).to_i, # Convert to satangs
        currency: "thb",
        customer: customer.id,
        description: "Subscription to #{plan} plan"
      )

      if charge.paid
        # Create a subscription record
        subscription = Current.user.subscriptions.create!(
          plan_name: plan,
          status: "active",
          started_at: Time.now,
          expires_at: 1.month.from_now
        )

        # Create a payment record
        payment = subscription.payments.create!(
          user: Current.user,
          amount: amount,
          status: "successful",
          omise_charge_id: charge.id,
          paid_at: Time.now
        )

        # Update user's subscription status
        Current.user.update(
          subscription_status: "active",
          subscription_end_date: 1.month.from_now
        )

        redirect_to subscription_path(subscription), notice: "Payment successful! Your subscription is now active."
      else
        redirect_to new_payment_path, alert: "Payment failed: #{charge.failure_message}"
      end
    rescue Omise::Error => e
      Rails.logger.error "Omise Error: #{e.message}"
      redirect_to new_payment_path, alert: "Payment error: #{e.message}"
    end
  end

  def show
    @payment = Current.user.payments.find(params[:id])
  end

  def success
    redirect_to root_path, notice: "Your payment was successful!"
  end

  def failure
    redirect_to root_path, alert: "Your payment could not be processed. Please try again."
  end

  def webhook
    # Parse the webhook payload
    payload = JSON.parse(request.body.read)
    event = payload["data"]

    case payload["key"]
    when "charge.complete"
      # A charge was completed (approved or rejected)
      process_charge_complete(event)
    when "customer.update"
      # Customer was updated
      process_customer_update(event)
    when "subscription.create", "subscription.update"
      # A subscription was created or updated
      process_subscription_update(event)
    end

    head :ok
  end

  private

  def find_or_create_customer(token)
    if Current.user.omise_customer_id.present?
      begin
        customer = Omise::Customer.retrieve(Current.user.omise_customer_id)

        # Update the customer's card
        customer.update(card: token)

        return customer
      rescue Omise::Error => e
        Rails.logger.error "Failed to retrieve customer: #{e.message}"
        # Falls through to create a new customer
      end
    end

    # Create a new customer
    Omise::Customer.create(
      email: Current.user.email_address,
      description: "Customer for #{Current.user.email_address}",
      card: token
    )
  end

  def get_plan_amount_for(plan_name)
    case plan_name
    when "premium"
      599.0 # ฿599 per month
    else
      0.0
    end
  end

  def process_charge_complete(event)
    charge_id = event["id"]
    payment = Payment.find_by(omise_charge_id: charge_id)

    if payment
      if event["status"] == "successful"
        payment.update(status: "successful", paid_at: Time.now)

        # If this payment is associated with a subscription, activate the subscription
        if payment.subscription
          payment.subscription.update(status: "active")
          payment.user.update(subscription_status: "active", subscription_end_date: payment.subscription.expires_at)
        end
      else
        payment.update(status: event["status"])

        # If payment failed and is associated with a subscription, put subscription in grace period
        if event["status"] == "failed" && payment.subscription
          payment.subscription.update(status: "grace", expires_at: Time.now + 30.days)
          payment.user.update(subscription_status: "grace", subscription_end_date: payment.subscription.expires_at)
        end
      end
    end
  end

  def process_customer_update(event)
    customer_id = event["id"]
    user = User.find_by(omise_customer_id: customer_id)

    # Log the update
    Rails.logger.info "Customer updated: #{customer_id}" if user
  end

  def process_subscription_update(event)
    # This would be used if you implement recurring billing through Omise
    subscription_id = event["id"]

    # For now, just log the event
    Rails.logger.info "Subscription event: #{event['key']} for ID: #{subscription_id}"
  end
end