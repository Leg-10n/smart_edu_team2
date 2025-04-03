class AddSchoolToUsers < ActiveRecord::Migration[8.0]
  def change
    # add default so that existing entries without refkey wont break
    default_school_id = School.first.try(:id) || School.create(name: 'Default School').id
    add_reference :users, :school, null: false, foreign_key: true, default: default_school_id
    # set default back to nil, so that the null constraint will stop further creation from creating without refkey
    change_column_default :users, :school_id, nil
  end
end
