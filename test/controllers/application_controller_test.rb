require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(:adminA)
  end

  test "should have dynamically defined methods for roles" do
    # Create a controller instance directly for testing its methods
    controller = ApplicationController.new

    # Mock the current_user method to return a user with a specific role
    def controller.current_user
      OpenStruct.new(role: "admin")
    end

    # Get the ROLES constant from the UserRole module
    UserRole::ROLES.each do |role|
      method_name = "#{role}?"

      # Check if the method exists
      assert_respond_to controller, method_name, "Expected method #{method_name} to be defined"

      # Check if the method returns the expected value based on the mocked user's role
      if role == "admin"
        assert controller.send(method_name), "#{method_name} should return true when role is admin"
      else
        assert_not controller.send(method_name), "#{method_name} should return false when role is not #{role}"
      end
    end
  end
end
