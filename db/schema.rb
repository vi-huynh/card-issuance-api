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

ActiveRecord::Schema[7.2].define(version: 2026_08_07_081238) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.string "auditable_type", null: false
    t.bigint "auditable_id", null: false
    t.jsonb "object", default: {}
    t.jsonb "object_changes", default: {}
    t.inet "ip_address"
    t.datetime "created_at", null: false
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "logo_url"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "product_id", null: false
    t.string "activation_number", null: false
    t.string "pin"
    t.integer "status", default: 0, null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.decimal "current_balance", precision: 12, scale: 2, null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.jsonb "purchase_details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activation_number"], name: "index_cards_on_activation_number", unique: true
    t.index ["client_id"], name: "index_cards_on_client_id"
    t.index ["product_id"], name: "index_cards_on_product_id"
    t.index ["status"], name: "index_cards_on_status"
  end

  create_table "client_products", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.index ["client_id", "product_id"], name: "index_client_products_on_client_id_and_product_id", unique: true
    t.index ["client_id"], name: "index_client_products_on_client_id"
    t.index ["product_id"], name: "index_client_products_on_product_id"
  end

  create_table "clients", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.decimal "payout_rate", precision: 10, scale: 2
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_clients_on_status"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.string "name", null: false
    t.decimal "price", precision: 12, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.string "invite_token_digest"
    t.datetime "invite_token_expires_at"
    t.datetime "invited_at"
    t.datetime "invite_accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "audit_logs", "users", on_delete: :restrict
  add_foreign_key "cards", "clients", on_delete: :restrict
  add_foreign_key "cards", "products", on_delete: :restrict
  add_foreign_key "client_products", "clients", on_delete: :cascade
  add_foreign_key "client_products", "products", on_delete: :restrict
  add_foreign_key "clients", "users", on_delete: :cascade
  add_foreign_key "products", "brands", on_delete: :restrict
end
