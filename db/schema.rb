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

ActiveRecord::Schema[8.1].define(version: 2026_06_23_000005) do
  create_table "reservations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_time", null: false
    t.integer "seat_id", null: false
    t.datetime "start_time", null: false
    t.string "status", default: "confirmed", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["seat_id", "start_time", "end_time"], name: "index_reservations_on_seat_id_and_start_time_and_end_time"
    t.index ["seat_id"], name: "index_reservations_on_seat_id"
    t.index ["user_id", "created_at"], name: "index_reservations_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "seats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "equipment_notes"
    t.boolean "has_monitor", default: false
    t.boolean "has_power_outlet", default: true
    t.boolean "is_active", default: true
    t.string "seat_number", null: false
    t.datetime "updated_at", null: false
    t.integer "zone_id", null: false
    t.index ["zone_id", "seat_number"], name: "index_seats_on_zone_id_and_seat_number", unique: true
    t.index ["zone_id"], name: "index_seats_on_zone_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.decimal "balance_after", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "reservation_id"
    t.string "transaction_type", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["reservation_id"], name: "index_transactions_on_reservation_id"
    t.index ["transaction_type"], name: "index_transactions_on_transaction_type"
    t.index ["user_id", "created_at"], name: "index_transactions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "auth_token"
    t.decimal "balance", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.boolean "is_admin", default: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "phone", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  create_table "zones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "hourly_rate", precision: 10, scale: 2, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "zone_type", null: false
  end

  add_foreign_key "reservations", "seats"
  add_foreign_key "reservations", "users"
  add_foreign_key "seats", "zones"
  add_foreign_key "transactions", "reservations"
  add_foreign_key "transactions", "users"
end
