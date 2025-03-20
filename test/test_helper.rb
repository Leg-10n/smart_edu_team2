ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "./test/helpers/authentication_helper"

def ci?
  ENV["CI"] == "true"
end
module SignInHelper
  def sign_in(user_fixture)
    user = users(user_fixture)
    post session_url, params: { email_address: user.email_address, password: "password" }
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 8)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
