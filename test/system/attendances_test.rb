require "application_system_test_case"

class AttendancesTest < ApplicationSystemTestCase
  setup do
    @attendance = attendances(:attendance_1)
    login(:teacherA)
  end

  test "visiting the index" do
    visit attendances_url
    assert_selector "h2 span", text: "Attendances"
  end

  # test "should create attendance" do
  #   visit new_attendance_url
  #   within 'tr[data-content="Student 6"]' do
  #     click_on "Check-in"
  #   end
  #   first_row = "table#latest-attendances tbody tr:first-of-type td:first-of-type"
  #   assert_selector first_row, text: "Student 6"
  # end
end
