class AddOmiseCustomerIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :omise_customer_id, :string
  end
end
