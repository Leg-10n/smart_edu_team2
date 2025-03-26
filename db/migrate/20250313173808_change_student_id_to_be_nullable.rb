class ChangeStudentIdToBeNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :attendances, :student_id, true
  end
end
