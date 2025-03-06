# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  first_name      :string
#  is_active       :boolean          default(TRUE)
#  last_name       :string
#  password_digest :string           not null
#  role            :string           default("unassigned")
#  uuid            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_uuid           (uuid) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should save user" do
    user = User.new email_address: "a3333@bbb.com", password: "password"
    assert user.save
  end

  test "should not save user without email" do
    user = User.new email_address: "", password: "password"
    assert_not user.save
  end

  test "should not save user short password" do
    user = User.new email_address: "a@a.com", password: "123567"
    assert_not user.save
  end

  test "should not save user with stupidly long password password" do
    user = User.new email_address: "a@a.com", password: "123456789012345678901"
    assert_not user.save
  end

  test "should not save invalid email" do
    user = User.new email_address: "a.com", password: "12345678"
    assert_not user.save
  end

  test "should not save user with duplicated email" do
    user = User.new email_address: "a222@bbb.com", password: "password"
    assert user.save
    user = User.new email_address: "a222@bbb.com", password: "password"
    assert_not user.save
  end
end
