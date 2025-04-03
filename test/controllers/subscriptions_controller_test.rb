require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email: @user.email, password: "password" }

    @subscription = subscriptions(:one)
  end

  test "should get new" do
    get new_subscription_path
    assert_response :success
  end

  test "should get index" do
    get subscriptions_path
    assert_response :success
  end

  test "should get show" do
    get subscription_path(@subscription)
    assert_response :success
  end
end
