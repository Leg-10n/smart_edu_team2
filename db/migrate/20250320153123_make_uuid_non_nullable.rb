class MakeUuidNonNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :uuid, false
  end
end
