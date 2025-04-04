class AddSchoolToAttendances < ActiveRecord::Migration[8.0]
  def change
    add_reference :attendances, :school, null: true, foreign_key: true
  end
end
