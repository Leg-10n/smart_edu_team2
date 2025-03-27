require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index when logged in" do
    sign_in(:adminA)
    get root_path
    assert_response :success
    assert_includes @response.body, "Total Students"
  end

  test "not logged in should get redirected to login" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "should get home access by all roles" do
    [ :studentA, :adminA, :one, :studentA ].each do |user|
      sign_in(user)
      get root_path
      assert_response :success
      assert_includes @response.body, "<title>Dashboard</title>"
    end
  end
end
