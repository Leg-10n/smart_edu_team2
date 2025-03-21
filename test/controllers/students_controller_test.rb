require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = students(:student_1)
    sign_in(:teacherA)
  end

  test "should get index" do
    get students_url
    assert_response :success
  end

  test "should get new" do
    get new_student_url
    assert_response :success
  end

  test "should create student" do
    assert_difference("Student.count") do
      post students_url, params: { student: { name: "newstudent" } }
    end

    assert_redirected_to student_url(Student.last)
  end

  test "should show student" do
    get student_url(@student)
    assert_equal @controller.student.id, @student.id
    assert_response :success
  end

  test "should get edit" do
    get edit_student_url(@student)
    assert_response :success
  end

  test "should update student" do
    patch student_url(@student), params: { student: { name: "newname" } }
    assert_redirected_to student_url(@student)
  end

  test "should destroy student" do
    assert_difference("Student.kept.count", -1) do
      delete student_url(@student)
    end

    assert_redirected_to students_url
  end

  test "should not be able to access student index without teacher roles" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      get students_url
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end

  test "should not be able to access student info page without teacher roles" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      get student_url(@student)
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end

  test "create action should only be accesible by teachers" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      assert_no_difference("Student.count") do
        post students_url, params: { student: { name: "newstudent", uid: SecureRandom.uuid } }
      end
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end

  test "edit action should only be accesible by teachers" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      get edit_student_url(@student)
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end

  test "update action should only be accesible by teachers" do
    [ :adminA, :studentA, :one ].each do |user|
      sign_in(user)
      updating_student = @student
      assert_no_changes(-> { updating_student.reload; updating_student.name }) do
        patch student_url(updating_student), params: { student: { name: "newstudentA" } }
      end
      updating_student.reload
      assert_equal "Student 1", updating_student.name
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end
end
