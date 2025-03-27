class ChangeUserIdToNullableAndAddNotNullToStudentIdInAttendances < ActiveRecord::Migration[6.0]
  def change
    # Change user_id to be nullable
    change_column_null :attendances, :user_id, true

    # Make student_id not null
    change_column_null :attendances, :student_id, false
  end
end
