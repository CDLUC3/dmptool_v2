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

ActiveRecord::Schema.define(version: 20131114000149) do

  create_table "additional_informations", force: true do |t|
    t.string   "url"
    t.string   "label"
    t.integer  "requirements_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.enum     "provider",   limit: [:shibboleth, :ldap]
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authorizations", force: true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["user_id", "role_id"], name: "index_authorizations_on_user_id_and_role_id", unique: true, using: :btree

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.enum     "visibility", limit: [:owner, :reviewer]
    t.integer  "plan_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enumerations", force: true do |t|
    t.integer  "requirement_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.integer  "requirements_template_id"
    t.string   "text_brief"
    t.boolean  "is_subgroup"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "logo"
    t.string   "ancestry"
    t.datetime "deleted_at"
  end

  add_index "institutions", ["ancestry"], name: "index_institutions_on_ancestry", using: :btree

  create_table "labels", force: true do |t|
    t.string   "desc"
    t.string   "group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plan_states", force: true do |t|
    t.integer  "plan_id"
    t.enum     "state",      limit: [:new, :committed, :submitted, :approved, :rejected, :revised, :inactive, :deleted]
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.string   "name"
    t.integer  "requirements_template_id"
    t.string   "solicitation_identifier"
    t.datetime "submission_deadline"
    t.enum     "visibility",               limit: [:institutional, :public, :public_browsable]
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_plan_state_id"
  end

  create_table "published_plans", force: true do |t|
    t.integer  "plan_id"
    t.string   "file_name"
    t.enum     "visibility", limit: [:institutional, :public, :public_browsable]
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requirements", force: true do |t|
    t.integer  "order"
    t.string   "text_brief"
    t.text     "text_full"
    t.enum     "requirement_type",         limit: [:text, :numeric, :date, :enum]
    t.enum     "obligation",               limit: [:mandatory, :mandatory_applicable, :recommended, :optional]
    t.text     "default"
    t.integer  "requirements_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.boolean  "group"
    t.integer  "group_id"
  end

  add_index "requirements", ["ancestry"], name: "index_requirements_on_ancestry", using: :btree

  create_table "requirements_templates", force: true do |t|
    t.integer  "institution_id"
    t.string   "name"
    t.boolean  "active"
    t.datetime "start_date"
    t.datetime "end_date"
    t.enum     "visibility",     limit: [:public, :institutional]
    t.integer  "version"
    t.integer  "parent_id"
    t.enum     "review_type",    limit: [:formal_review, :informal_review, :no_review]
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_templates", force: true do |t|
    t.integer  "institution_id"
    t.integer  "requirements_template_id"
    t.string   "name"
    t.boolean  "active",                                                                          default: false
    t.enum     "review_type",              limit: [:formal_review, :informal_review, :no_review]
    t.string   "widget_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_info"
    t.string   "contact_email"
  end

  create_table "resources", force: true do |t|
    t.enum     "resource_type",        limit: [:actionable_url, :expository_guidance, :example_response, :suggested_response]
    t.string   "value"
    t.string   "label"
    t.integer  "requirement_id"
    t.integer  "resource_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text"
  end

  create_table "responses", force: true do |t|
    t.integer  "plan_id"
    t.integer  "requirement_id"
    t.integer  "label_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_plans", force: true do |t|
    t.string   "url"
    t.string   "label"
    t.integer  "requirements_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.integer  "requirements_template_id"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_plans", force: true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.boolean  "owner"
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
    t.string   "cookie_salt"
    t.string   "login_id"
    t.boolean  "active",           default: true
    t.datetime "deleted_at"
  end

end
