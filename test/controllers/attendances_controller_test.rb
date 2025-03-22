require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attendance = attendances(:attendance_1)
    @user = users(:one) # Update with a valid fixture
    sign_in # Devise helper
  end

  test "should get index" do
    get attendances_url
    assert_response :success
  end

  test "should get new" do
    get new_attendance_url
    assert_response :success
  end

  test "should create attendance" do
    assert_difference("Attendance.count", 1) do
      post attendances_url, params: { user_id: users(:one).id }, as: :json
      puts @response.body
    end
    assert_response :created
    assert_match /Attendance successfully recorded/, @response.body
  end

  test "should not create attendance with invalid params" do
    assert_no_difference("Attendance.count") do
      post attendances_url, params: { user_id: nil }, as: :json
    end
    assert_response :unprocessable_entity
    assert_match /User must exist/, @response.body
  end

  test "should show attendance" do
    get attendance_url(@attendance)
    assert_response :success
  end

  test "should get edit" do
    get edit_attendance_url(@attendance)
    assert_response :success
  end

  test "should update attendance" do
    patch attendance_url(@attendance), params: { attendance: { user_id: @user.id } }
    assert_redirected_to attendance_url(@attendance)
    follow_redirect!
    assert_match /Attendance was successfully updated/, response.body
  end

  test "should not update attendance with invalid params" do
    patch attendance_url(@attendance), params: { attendance: { user_id: nil } }
    assert_response :unprocessable_entity
  end

  test "should destroy attendance" do
    assert_difference("Attendance.count", -1) do
      delete attendance_url(@attendance)
    end
    assert_redirected_to attendances_url
  end
end
