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

ActiveRecord::Schema.define(version: 20160915204432) do

  create_table "makes", force: :cascade do |t|
    t.string   "name"
    t.integer  "webmotors_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "makes", ["name"], name: "index_makes_on_name", unique: true
  add_index "makes", ["webmotors_id"], name: "index_makes_on_webmotors_id"

  create_table "models", force: :cascade do |t|
    t.integer  "make_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "models", ["name", "make_id"], name: "index_models_on_name_and_make_id", unique: true

end
