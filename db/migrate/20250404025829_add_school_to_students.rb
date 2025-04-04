class AddSchoolToStudents < ActiveRecord::Migration[8.0]
  def change
    add_reference :students, :school, null: true, foreign_key: true
  end
end
