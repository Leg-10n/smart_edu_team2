require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attendance = attendances(:attendance_1)
    sign_in(:teacherA)
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

  test "should not be able to access attendances index without teacher roles" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      get attendances_url
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end

  test "should not be able to access attendances info page without teacher roles" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      get attendance_url(attendances(:attendance_5))
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end

  test "create action should only be accesible by teachers" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      teacher = users(:teacherA)
      student = students(:student_1)
      assert_no_difference("Attendance.count") do
        post attendances_url, params: { attendance: { student_id: student.id, user_id: teacher.id, timestamp: Time.now } }
      end
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end

  test "edit action should only be accesible by teachers" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      get edit_attendance_url(@attendance)
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end

  test "update action should only be accesible by teachers" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      updating_attendance = attendances(:attendance_5)
      original_timestamp = updating_attendance.timestamp
      assert_no_changes(-> { updating_attendance.reload; updating_attendance.timestamp }) do
        patch attendance_url(updating_attendance), params: { attendance: { timestamp: Time.now } }
      end
      updating_attendance.reload
      assert_equal original_timestamp, updating_attendance.timestamp
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end
end
