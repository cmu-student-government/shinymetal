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

ActiveRecord::Schema.define(version: 20150304225636) do

  create_table "approvals", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_key_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text     "message"
    t.boolean  "is_private"
    t.integer  "user_id"
    t.integer  "user_key_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "filters", force: :cascade do |t|
    t.string   "resource"
    t.string   "filter_name"
    t.string   "filter_value"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.integer  "external_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "user_key_filters", force: :cascade do |t|
    t.integer  "user_key_id"
    t.integer  "filter_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "user_key_organizations", force: :cascade do |t|
    t.integer  "user_key_id"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "user_keys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "status",           default: "awaiting_submission"
    t.datetime "time_submitted"
    t.datetime "time_filtered"
    t.datetime "time_confirmed"
    t.datetime "time_expired"
    t.boolean  "active",           default: true
    t.text     "reason"
    t.string   "value"
    t.text     "application_text"
    t.boolean  "agree",            default: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "andrew_id"
    t.string   "role",       default: "requester"
    t.boolean  "active",     default: true
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

end
