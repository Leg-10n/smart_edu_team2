class MakeSchoolNameNotNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :schools, :name, false
  end
end
