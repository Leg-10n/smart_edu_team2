# config/initializers/scheduler.rb
require "rufus-scheduler"

scheduler = Rufus::Scheduler.singleton

scheduler.every "1d" do
  CheckSubscriptionStatusJob.perform_later
end
