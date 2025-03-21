class PaymentsController < ApplicationController
  include Authentication

  before_action :require_authentication, except: [ :success, :failure, :webhook ]
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  def new
    # Display payment form
    redirect_to root_path, alert: "You're already subscribed!" if Current.user&.subscribed?
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
      omise_customer = find_or_create_customer(token)

      # Store the customer ID with the user
      Current.user.update(omise_customer_id: omise_customer.id) unless Current.user.omise_customer_id.present?

      # Set up a subscription
      subscription = OmiseService.create_subscription(
        omise_customer.id,
        get_plan_id_for(plan)
      )

      # Create a subscription record in our database
      @subscription = Current.user.subscriptions.create!(
        plan_name: plan,
        omise_subscription_id: subscription.id,
        status: subscription.status,
        started_at: Time.now,
        expires_at: 1.month.from_now
      )

      # Create a payment record
      @payment = @subscription.payments.create!(
        user: Current.user,
        amount: get_plan_amount_for(plan),
        status: "successful",
        omise_charge_id: subscription.id, # Using subscription ID for reference
        paid_at: Time.now
      )

      # Update user's subscription status
      SubscriptionService.activate_subscription(@subscription)

      redirect_to subscription_path(@subscription), notice: "Subscription successful! Thank you for your payment."
    rescue Omise::Error => e
      Rails.logger.error "Omise Error: #{e.message}"
      redirect_to new_payment_path, alert: "Payment error: #{e.message}"
    end
  end

  def show
    @payment = Current.user.payments.find(params[:id])
  end

  def success
    # Handle successful payments
    redirect_to root_path, notice: "Your payment was successful!"
  end

  def failure
    # Handle failed payments
    redirect_to root_path, alert: "Your payment could not be processed. Please try again."
  end

  def webhook
    # Parse the webhook payload
    payload = JSON.parse(request.body.read)
    event = payload["data"]

    case payload["key"]
    when "charge.create"
      # A new charge was created
      process_charge_create(event)

    when "charge.complete"
      # A charge was completed (approved or rejected)
      process_charge_complete(event)

    when "customer.update"
      # Customer was updated
      process_customer_update(event)

    when "subscription.create"
      # A new subscription was created
      process_subscription_create(event)

    when "subscription.renew"
      # A subscription was renewed
      process_subscription_renew(event)

    when "subscription.delete"
      # A subscription was canceled or expired
      process_subscription_delete(event)

    when "subscription.suspend"
      # A subscription was suspended due to failed payment
      process_subscription_suspend(event)
    end

    head :ok
  end

  private

  def find_or_create_customer(token)
    if Current.user.omise_customer_id.present?
      begin
        customer = OmiseService.retrieve_customer(Current.user.omise_customer_id)
        return customer
      rescue Omise::Error
        # Customer not found, create a new one
      end
    end

    # Create a new customer
    OmiseService.create_customer(Current.user, token)
  end

  def get_plan_id_for(plan_name)
    case plan_name
    when "premium"
      "plan_premium_monthly" # This should be created in your Omise dashboard
    else
      raise "Unknown plan: #{plan_name}"
    end
  end

  def get_plan_amount_for(plan_name)
    case plan_name
    when "premium"
      599.0 # ฿599 per month
    else
      0.0
    end
  end

  def process_charge_create(event)
    # Log the charge creation
    Rails.logger.info "Charge created: #{event['id']}"
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
        end
      else
        payment.update(status: event["status"])

        # If payment failed and is associated with a subscription, put subscription in grace period
        if event["status"] == "failed" && payment.subscription
          payment.subscription.update(status: "grace", expires_at: Time.now + 30.days)
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

  def process_subscription_create(event)
    subscription_id = event["id"]
    subscription = Subscription.find_by(omise_subscription_id: subscription_id)

    if subscription
      subscription.update(status: event["status"])

      # Activate the subscription if status is active
      if event["status"] == "active"
        subscription.update(status: "active", expires_at: 1.month.from_now)
      end
    end
  end

  def process_subscription_renew(event)
    subscription_id = event["id"]
    subscription = Subscription.find_by(omise_subscription_id: subscription_id)

    if subscription
      # Process the renewal
      new_end_date = subscription.expires_at + 1.month
      subscription.update(expires_at: new_end_date, status: "active")

      # Create a new payment record if there's a charge
      if event["charge"].present? && event["charge"]["id"].present?
        subscription.payments.create!(
          user: subscription.user,
          amount: get_plan_amount_for(subscription.plan_name),
          status: "successful",
          omise_charge_id: event["charge"]["id"],
          paid_at: Time.now
        )
      end
    end
  end

  def process_subscription_delete(event)
    subscription_id = event["id"]
    subscription = Subscription.find_by(omise_subscription_id: subscription_id)

    if subscription
      # Process the cancellation
      subscription.update(status: "canceled")
    end
  end

  def process_subscription_suspend(event)
    subscription_id = event["id"]
    subscription = Subscription.find_by(omise_subscription_id: subscription_id)

    if subscription
      subscription.update(status: "suspended")

      # Put the subscription in grace period
      subscription.update(status: "grace", expires_at: Time.now + 30.days)
    end
  end
end
