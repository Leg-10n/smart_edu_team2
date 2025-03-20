class AddUuidsToExistingUsers < ActiveRecord::Migration[8.0]
  def change
    # Update users with nil or empty uuid with one (no validation)
    User.where(uuid: [ nil, '' ]).find_each do |user|
      user.update_column(:uuid, SecureRandom.uuid)
    end
  end
end
