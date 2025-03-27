# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

user1 = User.create(
  email_address: "one@example.com",
  password_digest: BCrypt::Password.create("password"),
  role: "unassigned",
  uuid: SecureRandom.uuid
)

user2 = User.create(
  email_address: "admina1@test.com",
  password_digest: BCrypt::Password.create("password"),
  role: "admin",
  uuid: SecureRandom.uuid
)
