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

ActiveRecord::Schema.define(version: 20130521210544) do

  create_table "institutions", force: true do |t|
    t.string   "full_name"
    t.string   "nickname"
    t.text     "desc"
    t.string   "contact_info"
    t.string   "contact_email"
    t.string   "url"
    t.string   "url_text"
    t.string   "shib_entity_id"
    t.string   "shib_domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.integer  "institution_id"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "token"
    t.datetime "token_expiration"
    t.binary   "prefs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
