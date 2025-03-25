class AddSubscriptionStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :subscription_status, :string, default: 'free'
    add_column :users, :subscription_end_date, :datetime
  end
end
