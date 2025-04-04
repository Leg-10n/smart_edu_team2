class ChangeSchoolNameColumnNameToSchoolName < ActiveRecord::Migration[8.0]
  def change
    rename_column :schools, :name, :school_name
  end
end
