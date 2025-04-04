# test/controllers/subscriptions_controller_test.rb
require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Log in a user before running tests
    @user = users(:ownerA) # Use an existing fixture
    sign_in(@user)
    # Match the exact parameter names expected by SessionsController
    # post session_url, params: {
    #   email_address: @user.email_address,
    #   password: "password"
    # }

    @subscription = subscriptions(:owner_subscription)
  end

  # test "should get new" do
  #   get new_subscription_path
  #   assert_response :success
  # end

  # test "should get index" do
  #   get subscriptions_path
  #   assert_response :success
  # end

  # test "should get show" do
  #   get subscription_path(@subscription)
  #   assert_response :success
  # end
end
