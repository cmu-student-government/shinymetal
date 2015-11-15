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

ActiveRecord::Schema.define(version: 20151111192059) do

  create_table "answers", force: :cascade do |t|
    t.integer  "user_key_id"
    t.integer  "question_id"
    t.text     "message"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "approvals", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_key_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "approvals", ["user_key_id"], name: "index_approvals_on_user_key_id"

  create_table "columns", force: :cascade do |t|
    t.string   "resource",    limit: 255
    t.string   "column_name", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "columns", ["resource", "column_name"], name: "index_columns_on_resource_and_column_name"

  create_table "comments", force: :cascade do |t|
    t.text     "message"
    t.boolean  "public",      default: false
    t.integer  "user_id"
    t.integer  "user_key_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "comments", ["user_key_id"], name: "index_comments_on_user_key_id"

  create_table "express_apps", force: :cascade do |t|
    t.integer  "requester_type"
    t.text     "reasoning"
    t.text     "requester_additional_info"
    t.boolean  "tos_agree"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "user_key_id"
  end

  add_index "express_apps", ["user_key_id"], name: "index_express_apps_on_user_key_id"

  create_table "filters", force: :cascade do |t|
    t.string   "resource",     limit: 255
    t.string   "filter_name",  limit: 255
    t.string   "filter_value", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "filters", ["resource", "filter_name", "filter_value"], name: "resource_name_value_index"

  create_table "organizations", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "external_id"
    t.boolean  "active",                  default: true
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name"

  create_table "pages", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "url",        limit: 255
    t.text     "message"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "questions", force: :cascade do |t|
    t.text     "message"
    t.boolean  "required"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "user_key_columns", force: :cascade do |t|
    t.integer  "user_key_id"
    t.integer  "column_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "user_key_columns", ["user_key_id", "column_id"], name: "index_user_key_columns_on_user_key_id_and_column_id"

  create_table "user_key_organizations", force: :cascade do |t|
    t.integer  "user_key_id"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "user_key_organizations", ["user_key_id", "organization_id"], name: "user_org_association_index"

  create_table "user_keys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "status",         limit: 255, default: "awaiting_submission"
    t.datetime "time_submitted"
    t.datetime "time_filtered"
    t.datetime "time_confirmed"
    t.date     "time_expired"
    t.boolean  "active",                     default: true
    t.string   "name",           limit: 255
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
  end

  add_index "user_keys", ["time_submitted", "time_filtered", "time_confirmed", "time_expired"], name: "user_key_ordering_index"
  add_index "user_keys", ["user_id"], name: "user_key_fetching_index"

  create_table "users", force: :cascade do |t|
    t.string   "andrew_id",  limit: 255
    t.string   "role",       limit: 255, default: "requester"
    t.boolean  "active",                 default: true
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
  end

  add_index "users", ["andrew_id"], name: "index_users_on_andrew_id"

  create_table "whitelist_filters", force: :cascade do |t|
    t.integer  "whitelist_id"
    t.integer  "filter_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "whitelist_filters", ["whitelist_id", "filter_id"], name: "index_whitelist_filters_on_whitelist_id_and_filter_id"

  create_table "whitelists", force: :cascade do |t|
    t.integer  "user_key_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "whitelists", ["user_key_id"], name: "index_whitelists_on_user_key_id"

end
