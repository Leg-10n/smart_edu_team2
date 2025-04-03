class MakeUserSchoolNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :school_id, true
  end
end
