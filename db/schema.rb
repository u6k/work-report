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

ActiveRecord::Schema.define(version: 2018_05_29_065416) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "github_activities", force: :cascade do |t|
    t.string "event_id"
    t.string "event_type"
    t.datetime "event_created"
    t.integer "event_payload_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "redmine_activities", force: :cascade do |t|
    t.string "entry_title"
    t.string "entry_link"
    t.string "entry_id"
    t.datetime "entry_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
