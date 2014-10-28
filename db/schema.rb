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

ActiveRecord::Schema.define(version: 20141028043634) do

  create_table "components", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.string   "category"
    t.integer  "organization_id"
    t.text     "css"
    t.text     "js"
    t.text     "layout"
    t.text     "format"
    t.text     "gui_css"
    t.text     "gui_js"
    t.text     "gui_templates"
    t.text     "gui_controls"
    t.text     "gui_section_nav"
    t.text     "gui_help"
    t.text     "gui_example"
    t.text     "gui_footer"
    t.text     "gui_content_toolbar"
    t.text     "gui_header"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "components", ["category"], name: "index_components_on_category"
  add_index "components", ["organization_id"], name: "index_components_on_organization_id"
  add_index "components", ["slug", "organization_id"], name: "index_components_on_slug_and_organization_id", unique: true

  create_table "documents", force: true do |t|
    t.string   "name"
    t.string   "edit_id"
    t.string   "view_id"
    t.text     "payload"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "template_id"
    t.integer  "organization_id"
    t.string   "lms_course_id"
    t.datetime "lms_published_at"
    t.integer  "component_id"
    t.integer  "component_version"
    t.string   "term_id"
  end

  add_index "documents", ["component_id"], name: "index_documents_on_component_id"
  add_index "documents", ["edit_id"], name: "index_documents_on_edit_id", unique: true
  add_index "documents", ["lms_course_id"], name: "index_documents_on_lms_course_id"
  add_index "documents", ["organization_id"], name: "index_documents_on_organization_id"
  add_index "documents", ["template_id"], name: "index_documents_on_template_id", unique: true
  add_index "documents", ["term_id"], name: "index_documents_on_term_id"
  add_index "documents", ["view_id"], name: "index_documents_on_view_id", unique: true

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lms_authentication_source"
    t.string   "lms_authentication_id"
    t.string   "lms_authentication_key"
    t.string   "lms_info_slug"
    t.string   "lms_id"
  end

  add_index "organizations", ["depth"], name: "index_organizations_on_depth"
  add_index "organizations", ["lft"], name: "index_organizations_on_lft"
  add_index "organizations", ["lms_id"], name: "index_organizations_on_lms_id"
  add_index "organizations", ["parent_id"], name: "index_organizations_on_parent_id"
  add_index "organizations", ["rgt"], name: "index_organizations_on_rgt"
  add_index "organizations", ["slug", "parent_id"], name: "index_organizations_on_slug_and_parent_id", unique: true

  create_table "templates", force: true do |t|
    t.string   "slug"
    t.text     "payload"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "templates", ["slug", "organization_id"], name: "index_templates_on_slug_and_organization_id", unique: true

  create_table "terms", force: true do |t|
    t.string   "slug"
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "start_date"
    t.integer  "duration"
    t.string   "cycle"
    t.integer  "sequence"
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "terms", ["slug", "organization_id"], name: "index_terms_on_slug_and_organization_id", unique: true

  create_table "versions", force: true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "number"
    t.integer  "reverted_from"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], name: "index_versions_on_created_at"
  add_index "versions", ["number"], name: "index_versions_on_number"
  add_index "versions", ["tag"], name: "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], name: "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], name: "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type"

end
