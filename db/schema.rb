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

ActiveRecord::Schema[8.1].define(version: 2026_10_20_174922) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "borrow_request_lenders", force: :cascade do |t|
    t.bigint "borrow_request_id"
    t.bigint "lender_id"
    t.integer "status", default: 0
    t.datetime "locked_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrow_request_id"], name: "index_borrow_request_lenders_on_borrow_request_id"
    t.index ["lender_id"], name: "index_borrow_request_lenders_on_lender_id"
  end

  create_table "borrow_requests", force: :cascade do |t|
    t.bigint "borrower_id"
    t.decimal "amount", precision: 40, scale: 24
    t.string "token_symbol", default: "SLT"
    t.decimal "proposed_interest_rate", precision: 5, scale: 2
    t.integer "duration_in_days"
    t.integer "status", default: 0
    t.datetime "locked_until"
    t.datetime "funded_at"
    t.integer "funded_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrower_id"], name: "index_borrow_requests_on_borrower_id"
    t.index ["status"], name: "index_borrow_requests_on_status"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "max_lending_interest_rate", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "token_rates", force: :cascade do |t|
    t.string "symbol", null: false
    t.string "name"
    t.integer "price_in_cents", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "index_token_rates_on_symbol", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "xaman"
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.json "tokens"
    t.string "address", null: false
    t.string "user_token"
    t.string "name"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.string "email"
    t.bigint "country_id"
    t.integer "verification_level", default: 0
    t.integer "custom_max_borrowing_amount"
    t.integer "score", default: 0
    t.index ["address"], name: "index_users_on_address", unique: true
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["name"], name: "index_users_on_name"
    t.index ["phone_number"], name: "index_users_on_phone_number"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end
end
