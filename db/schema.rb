# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090510014855) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "user_name"
    t.string   "name"
    t.boolean  "error_cloning_repository"
    t.datetime "repository_cloned_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["user_name", "name"], :name => "index_projects_on_user_name_and_name"

  create_table "references", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "sha"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "references", ["project_id", "name"], :name => "index_references_on_project_id_and_name"

  create_table "revisions", :force => true do |t|
    t.integer  "project_id"
    t.string   "sha"
    t.boolean  "error_generating_rdoc"
    t.datetime "rdoc_generated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "revisions", ["project_id", "sha"], :name => "index_revisions_on_project_id_and_sha"

end
