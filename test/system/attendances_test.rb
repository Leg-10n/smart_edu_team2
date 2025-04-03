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

  test "should mark student as present" do
    visit new_attendance_url

    # Find the correct table row in the students table
    row = find("table tbody tr", text: "Student 6", match: :first)

    within(row) do
      click_on "Check-in"
    end

    # Verify that "Present" appears in the same row
    within(row) do
      assert_text "Present"
    end
  end
end
