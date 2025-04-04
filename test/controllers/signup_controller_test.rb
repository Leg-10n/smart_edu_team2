require "test_helper"

class SignupControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  # test "user should become owner of school with specified name upon sign up" do
  #   post signup_url, params: { user: { email_address: "newowner1a@a.com", password: "aaaaaaaa", password_confirmation: "aaaaaaaa", first_name: "new owner 1aa", last_name: "new owner 1ab", school_name: "New School Name 1A" } }
  #   assert_response :success
  #   assert_redirected_to root_path
  #   assert_not_nil User.where(email_address: "newowner1a@a.com").and(User.where(role: "owner")).first
  #   assert_not_nil School.where(school_name: "New School Name 1A").first
  #   assert_equal User.where(email_address: "newowner1a@a.com").and(User.where(role: "owner")).first?.school_id == School.where(school_name: "New School Name 1A").first?.id
  # end
end
