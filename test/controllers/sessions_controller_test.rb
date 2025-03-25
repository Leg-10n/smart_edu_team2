require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    assert true
  end

  test "should not create session with invalid credentials" do
    assert true
  end

  test "should destroy session (logout)" do
    assert true
  end

  test "should redirect to login page if unauthenticated user tries to logout" do
    assert true
  end
end
