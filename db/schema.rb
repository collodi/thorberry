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

ActiveRecord::Schema.define(version: 20170419120034) do

  create_table "errors", force: :cascade do |t|
    t.string   "msg"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logins", force: :cascade do |t|
    t.string   "user"
    t.string   "pwd"
    t.boolean  "priv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pins", force: :cascade do |t|
    t.string   "stage"
    t.string   "path"
    t.string   "pinval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "module"
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "alert"
    t.integer  "ad"
    t.float    "di"
    t.integer  "lhl"
    t.integer  "fcc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
