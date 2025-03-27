require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to dashboard when logged in and visiting landing page" do
    sign_in(:adminA)
    get root_path
    assert_redirected_to "/dashboard"
  end

  test "not logged in should see landing page" do
    get root_path
    assert_response :success
    # Add assertions to verify landing page content if needed
  end

  test "not logged in should get redirected when trying to access dashboard" do
    get dashboard_path # or whatever route maps to the dashboard action
    assert_redirected_to new_session_path
  end

  test "should get dashboard access by all roles" do
    [ :studentA, :adminA, :one, :studentA ].each do |user|
      sign_in(user)
      get dashboard_path # or whatever route maps to the dashboard action
      assert_response :success
      assert_includes @response.body, "<title>Dashboard</title>"
      assert_includes @response.body, "Total Students"
    end
  end
end
