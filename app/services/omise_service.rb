# app/services/omise_service.rb
class OmiseService
  def self.create_customer(user, token)
    Omise::Customer.create(
      email: user.email_address,
      description: "Customer for #{user.email_address}",
      card: token
    )
  end

  def self.create_subscription(customer_id, plan_id)
    Omise::Subscription.create(
      customer: customer_id,
      plan: plan_id
    )
  end

  def self.create_charge(amount, customer_id, description = nil)
    Omise::Charge.create(
      amount: (amount * 100).to_i, # Convert to satangs (smallest currency unit)
      currency: "thb",
      customer: customer_id,
      description: description
    )
  end

  def self.retrieve_customer(customer_id)
    Omise::Customer.retrieve(customer_id)
  end

  def self.retrieve_subscription(subscription_id)
    Omise::Subscription.retrieve(subscription_id)
  end

  def self.cancel_subscription(subscription_id)
    subscription = retrieve_subscription(subscription_id)
    subscription.destroy
  rescue Omise::Error => e
    Rails.logger.error "Failed to cancel subscription: #{e.message}"
    false
  end
end
