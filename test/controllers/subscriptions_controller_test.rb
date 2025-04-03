require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_subscription_path
    assert_response :success
  end

  test "should get index" do
    get subscriptions_path
    assert_response :success
  end

  test "should get show" do
    # Assuming you have fixtures or a setup method that creates a subscription
    get subscription_path(subscriptions(:one))
    assert_response :success
  end
end
