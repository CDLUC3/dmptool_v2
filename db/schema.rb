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

ActiveRecord::Schema.define(version: 20151214170435) do

  create_table "additional_informations", force: true do |t|
    t.string   "url",                      limit: 255
    t.string   "label",                    limit: 255
    t.integer  "requirements_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annita", id: false, force: true do |t|
    t.integer "xnum"
  end

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.enum     "provider",   limit: [:shibboleth, :ldap]
    t.string   "uid",        limit: 191
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
    t.enum     "visibility",   limit: [:owner, :reviewer]
    t.integer  "plan_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.enum     "comment_type", limit: [:owner, :reviewer]
  end

  create_table "enumerations", force: true do |t|
    t.integer  "requirement_id"
    t.string   "value",          limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "default"
  end

  create_table "institutions", force: true do |t|
    t.string   "full_name",      limit: 191
    t.string   "nickname",       limit: 191
    t.text     "desc"
    t.string   "contact_info",   limit: 191
    t.string   "contact_email",  limit: 191
    t.string   "url",            limit: 191
    t.string   "url_text",       limit: 191
    t.string   "shib_entity_id", limit: 191
    t.string   "shib_domain",    limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo",           limit: 191
    t.string   "ancestry",       limit: 191
    t.datetime "deleted_at"
  end

  add_index "institutions", ["ancestry"], name: "index_institutions_on_ancestry", using: :btree

  create_table "labels", force: true do |t|
    t.string   "desc",           limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "requirement_id"
  end

  create_table "plan_states", force: true do |t|
    t.integer  "plan_id"
    t.enum     "state",      limit: [:new, :committed, :submitted, :approved, :reviewed, :rejected, :revised, :inactive, :deleted]
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.text     "name"
    t.integer  "requirements_template_id"
    t.string   "solicitation_identifier",  limit: 191
    t.datetime "submission_deadline"
    t.enum     "visibility",               limit: [:institutional, :public, :private, :unit]
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_plan_state_id"
  end

  create_table "published_plans", force: true do |t|
    t.integer  "plan_id"
    t.string   "file_name",  limit: 191
    t.enum     "visibility", limit: [:institutional, :public, :private]
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requirements", force: true do |t|
    t.integer  "position"
    t.string   "text_brief",               limit: 191
    t.text     "text_full"
    t.enum     "requirement_type",         limit: [:text, :numeric, :date, :enum]
    t.enum     "obligation",               limit: [:mandatory, :mandatory_applicable, :recommended, :optional]
    t.text     "default"
    t.integer  "requirements_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry",                 limit: 191
    t.boolean  "group"
  end

  add_index "requirements", ["ancestry"], name: "index_requirements_on_ancestry", using: :btree

  create_table "requirements_templates", force: true do |t|
    t.integer  "institution_id"
    t.string   "name",           limit: 255
    t.boolean  "active"
    t.date     "start_date"
    t.date     "end_date"
    t.enum     "visibility",     limit: [:public, :institutional]
    t.enum     "review_type",    limit: [:formal_review, :informal_review, :no_review]
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_contexts", force: true do |t|
    t.integer  "institution_id"
    t.integer  "requirements_template_id"
    t.integer  "requirement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id"
    t.text     "name"
    t.string   "contact_info"
    t.string   "contact_email"
    t.enum     "review_type",              limit: [:formal_review, :informal_review, :no_review]
  end

  add_index "resource_contexts", ["institution_id", "requirements_template_id", "requirement_id", "resource_id"], name: "unique_context_index", unique: true, using: :btree
  add_index "resource_contexts", ["institution_id"], name: "index_resource_contexts_on_institution_id", using: :btree
  add_index "resource_contexts", ["requirement_id"], name: "index_resource_contexts_on_requirement_id", using: :btree
  add_index "resource_contexts", ["requirements_template_id"], name: "index_resource_contexts_on_requirements_template_id", using: :btree
  add_index "resource_contexts", ["resource_id"], name: "index_resource_contexts_on_resource_id", using: :btree

  create_table "resources", force: true do |t|
    t.enum     "resource_type", limit: [:actionable_url, :help_text, :example_response, :suggested_response]
    t.text     "value"
    t.string   "label",         limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text"
  end

  create_table "responses", force: true do |t|
    t.integer  "plan_id"
    t.integer  "requirement_id"
    t.integer  "label_id"
    t.text     "text_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "numeric_value"
    t.date     "date_value"
    t.integer  "enumeration_id"
    t.integer  "lock_version",   default: 0, null: false
  end

  create_table "roles", force: true do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_plans", force: true do |t|
    t.string   "url",                      limit: 191
    t.string   "label",                    limit: 191
    t.integer  "requirements_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.integer  "requirements_template_id"
    t.string   "tag",                      limit: 191
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
    t.string   "email",            limit: 191
    t.string   "first_name",       limit: 191
    t.string   "last_name",        limit: 191
    t.string   "token",            limit: 191
    t.datetime "token_expiration"
    t.binary   "prefs"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login_id"
    t.date     "deleted_at"
    t.boolean  "active",           default: true
    t.string   "orcid_id"
    t.string   "auth_token"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree

end
