# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_04_035309) do
  create_table "attendances", force: :cascade do |t|
    t.integer "student_id"
    t.datetime "timestamp"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "school_id"
    t.index ["school_id"], name: "index_attendances_on_school_id"
    t.index ["student_id"], name: "index_attendances_on_student_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.integer "user_id", null: false
    t.string "status"
    t.string "omise_charge_id"
    t.datetime "paid_at"
    t.integer "subscription_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_payments_on_subscription_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "school_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.string "uid", null: false
    t.datetime "discarded_at"
    t.integer "school_id"
    t.index ["discarded_at"], name: "index_students_on_discarded_at"
    t.index ["school_id"], name: "index_students_on_school_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "plan_name"
    t.integer "user_id", null: false
    t.string "status"
    t.string "omise_subscription_id"
    t.datetime "started_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenantss", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.string "role", default: "unassigned"
    t.string "first_name"
    t.string "last_name"
    t.string "uuid", null: false
    t.integer "school_id"
    t.string "omise_customer_id"
    t.string "subscription_status", default: "free"
    t.datetime "subscription_end_date"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  add_foreign_key "attendances", "schools"
  add_foreign_key "attendances", "students"
  add_foreign_key "attendances", "users"
  add_foreign_key "payments", "subscriptions"
  add_foreign_key "payments", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "students", "schools"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "users", "schools"
end
