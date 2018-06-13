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

ActiveRecord::Schema.define(version: 2018_06_13_091504) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "tenancies", force: :cascade do |t|
    t.string "ref"
    t.string "address_1"
    t.string "post_code"
    t.string "current_balance"
    t.string "primary_contact_first_name"
    t.string "primary_contact_last_name"
    t.string "primary_contact_title"
    t.integer "assigned_user_id"
    t.string "priority_band"
    t.index ["assigned_user_id"], name: "index_tenancies_on_assigned_user_id"
    t.index ["ref"], name: "index_tenancies_on_ref", unique: true
  end

  create_table "tenancy_events", force: :cascade do |t|
    t.string "event_type"
    t.string "description"
    t.boolean "automated"
    t.integer "tenancy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["tenancy_id"], name: "index_tenancy_events_on_tenancy_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider_uid"
    t.string "provider"
    t.string "name"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
  end

end
