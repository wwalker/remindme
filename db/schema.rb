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

ActiveRecord::Schema[7.0].define(version: 2022_10_04_023852) do
  create_table "appointments", force: :cascade do |t|
    t.string "reminder_id"
    t.string "result"
    t.datetime "started_at", default: "2000-01-01 00:00:00"
    t.datetime "ended_at", default: "2000-01-01 00:00:00"
    t.datetime "deleted_at"
    t.string "timestamps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crons", force: :cascade do |t|
    t.string "reminder_id"
    t.string "entry"
    t.datetime "last_run", default: "2000-01-01 00:00:00"
    t.datetime "next_run", default: "2000-01-01 00:00:00"
    t.datetime "deleted_at"
    t.string "timestamps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notification_histories", force: :cascade do |t|
    t.string "result"
    t.datetime "started_at", default: "2000-01-01 00:00:00"
    t.datetime "ended_at", default: "2000-01-01 00:00:00"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cron_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "deleted_at"
    t.string "description"
    t.string "detail"
    t.integer "renotify_delay"
    t.string "timestamps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "todos", force: :cascade do |t|
    t.datetime "deleted_at"
    t.string "description"
    t.string "detail"
    t.integer "renotify_delay"
    t.string "timestamps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
