class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.string :plan_name
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.string :omise_subscription_id
      t.datetime :started_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end
