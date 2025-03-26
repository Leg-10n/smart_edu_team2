require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = users(:one)
    sign_in(:adminA)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { email_address: "newuser@a1.com", password: "aaaaaaaa", password_confirmation: "aaaaaaaa", role: "teacher" } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    get user_url(@user)
    assert_equal @controller.user.id, @user.id
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { role: "student" } }
    assert_redirected_to users_url
  end

  # test "should destroy user" do
  #   assert_difference("User.kept.count", -1) do
  #     delete user_url(@user)
  #   end

  #   assert_redirected_to users_url
  # end

  test "should not be able to access user index without admin roles" do
    [ :teacherA, :studentA, :one ].each do |user|
      sign_in(user)
      get users_url
      assert_redirected_to root_path
      assert_equal "You must have role [ admin ] to access the requested page.", flash[:alert]
    end
  end

  test "should not be able to access user info page without admin roles" do
    [ :teacherA, :studentA, :one ].each do |user|
      sign_in(user)
      get user_url(@user)
      assert_redirected_to root_path
      assert_equal "You must have role [ admin ] to access the requested page.", flash[:alert]
    end
  end

  test "create action should only be accesible by admins" do
    [ :teacherA, :studentA, :one ].each do |user|
      sign_in(user)
      assert_no_difference("User.count") do
        post users_url, params: { user: { email_address: "newuser@a1.com", password: "aaaaaaaa", password_confirmation: "aaaaaaaa", role: "teacher" } }
      end
      assert_redirected_to root_path
      assert_equal "You must have role [ admin ] to access the requested page.", flash[:alert]
    end
  end

  test "edit action should only be accesible by admins" do
    [ :teacherA, :studentA, :one ].each do |user|
      sign_in(user)
      get edit_user_url(@user)
      assert_redirected_to root_path
      assert_equal "You must have role [ admin ] to access the requested page.", flash[:alert]
    end
  end

  test "update action should only be accesible by admins" do
    updating_user = users(:two)
    original_role = updating_user.role
    sign_in(:adminA)
    patch user_url(updating_user), params: { user: { role: "teacher" } }
    updating_user.reload
    assert_redirected_to users_path
    assert_equal "User role updated successfully", flash[:notice]
    assert_equal "teacher", updating_user.role

    [ :teacherA, :studentA, :one ].each do |user|
      sign_in(user)
      assert_no_changes(-> { updating_user.reload; updating_user.role }) do
        patch user_url(updating_user), params: { user: { role: "student" } }
      end
      updating_user.reload
      assert_equal "teacher", updating_user.role
      assert_redirected_to root_path
      assert_equal "You must have role [ admin ] to access the requested page.", flash[:alert]
    end

    sign_in(:adminA)
    patch user_url(updating_user), params: { user: { role: original_role } }
    updating_user.reload
    assert_redirected_to users_path
    assert_equal "User role updated successfully", flash[:notice]
    assert_equal original_role, updating_user.role
  end
end
