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

ActiveRecord::Schema.define(version: 20170210192752) do

  create_table "reservations", force: :cascade do |t|
    t.integer  "user_id",             limit: 4
    t.integer  "room_id",             limit: 4
    t.datetime "start_dt"
    t.datetime "end_dt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",               limit: 255
    t.boolean  "is_block",                        default: false
    t.string   "deleted_by",          limit: 255
    t.string   "cc",                  limit: 255
    t.string   "config_option",       limit: 255
    t.boolean  "deleted",                         default: false
    t.string   "created_at_timezone", limit: 255
    t.string   "deleted_at_timezone", limit: 255
    t.datetime "deleted_at"
  end

  create_table "room_groups", force: :cascade do |t|
    t.string   "title",            limit: 255
    t.integer  "admin_roles_mask", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "code",             limit: 255
  end

  create_table "rooms", force: :cascade do |t|
    t.integer  "sort_order",        limit: 4
    t.string   "title",             limit: 255
    t.text     "description",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_of_room",      limit: 255
    t.string   "size_of_room",      limit: 255
    t.string   "image_link",        limit: 255
    t.text     "hours",             limit: 65535
    t.integer  "sort_size_of_room", limit: 4,     default: 0
    t.integer  "room_group_id",     limit: 4
    t.string   "opens_at",          limit: 255
    t.string   "closes_at",         limit: 255
    t.boolean  "collaborative"
  end

  create_table "users", force: :cascade do |t|
    t.string   "firstname",          limit: 255
    t.string   "lastname",           limit: 255
    t.string   "email",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",           limit: 255, default: "", null: false
    t.datetime "expiration_date"
    t.datetime "refreshed_at"
    t.integer  "admin_roles_mask",   limit: 4
    t.string   "provider",           limit: 255, default: "", null: false
    t.string   "aleph_id",           limit: 255
    t.string   "institution_code",   limit: 255
    t.string   "college",            limit: 255
    t.string   "dept_code",          limit: 255
    t.string   "department",         limit: 255
    t.string   "major_code",         limit: 255
    t.string   "major",              limit: 255
    t.string   "patron_status",      limit: 255
    t.string   "college_code",       limit: 255
    t.integer  "sign_in_count",      limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip", limit: 255
    t.string   "last_sign_in_ip",    limit: 255
  end

  add_index "users", ["username", "provider"], name: "index_users_on_username_and_provider", unique: true, using: :btree

end
