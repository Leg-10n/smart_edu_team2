Rails.application.config.solid_queue.define_periodic_job(
  "check_subscriptions",
  "CheckSubscriptionStatusJob",
  interval: 1.day
)
