class AddOmiseCustomerIdToUsers < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :omise_customer_id)
      add_column :users, :omise_customer_id, :string
    end

    unless column_exists?(:users, :subscription_status)
      add_column :users, :subscription_status, :string, default: 'free'
    end

    unless column_exists?(:users, :subscription_end_date)
      add_column :users, :subscription_end_date, :datetime
    end
  end
end
