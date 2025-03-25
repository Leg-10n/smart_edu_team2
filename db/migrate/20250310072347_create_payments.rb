class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.string :omise_charge_id
      t.datetime :paid_at
      t.references :subscription, null: false, foreign_key: true

      t.timestamps
    end
  end
end
