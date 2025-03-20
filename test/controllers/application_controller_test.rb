require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(:adminA)
  end

  test "should have dynamically defined methods for roles" do
    ApplicationController::ROLES.each do |role|
      method_name = "#{role}?" # We are testing the dynamic methods like `admin?`, `teacher?`, etc.

      # Assert that the methods exists
      assert_respond_to @controller, method_name, "Expected method #{method_name} to be defined"

      # dynamically call method "<role>?" and check response based on user roles
      if @controller.current_user&.role == role
        assert @controller.send(method_name), "#{method_name} should return true when role is #{role}"
      else
        assert_not @controller.send(method_name), "#{method_name} should return false when role is not #{role}"
      end
    end
  end
end
