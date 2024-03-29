# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150503044500) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "credentials", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.string   "type",       limit: 32,  null: false
    t.string   "name",       limit: 128
    t.datetime "updated_at",             null: false
    t.binary   "key"
  end

  add_index "credentials", ["type", "name"], name: "index_credentials_on_type_and_name", unique: true, using: :btree
  add_index "credentials", ["type", "updated_at"], name: "index_credentials_on_type_and_updated_at", using: :btree
  add_index "credentials", ["user_id", "type"], name: "index_credentials_on_user_id_and_type", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "exuid",      limit: 32,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                   null: false
    t.string   "name",       limit: 256
    t.string   "image",      limit: 1024
  end

  add_index "users", ["exuid"], name: "index_users_on_exuid", unique: true, using: :btree

  create_table "venues", force: :cascade do |t|
    t.string "name",     limit: 128, null: false
    t.string "twx_name", limit: 256
    t.float  "lat",                  null: false
    t.float  "long",                 null: false
    t.string "address",  limit: 128
    t.string "phone",    limit: 32
    t.text   "sensors",              null: false
  end

  add_index "venues", ["lat", "long"], name: "index_venues_on_lat_and_long", unique: true, using: :btree

end
