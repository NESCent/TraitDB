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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130321145441) do

  create_table "categorical_trait_categories", :force => true do |t|
    t.string   "name"
    t.integer  "categorical_trait_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "categorical_trait_values", :force => true do |t|
    t.integer  "position"
    t.integer  "otu_id"
    t.integer  "categorical_trait_id"
    t.integer  "categorical_trait_category_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "categorical_traits", :force => true do |t|
    t.string   "name"
    t.integer  "import_job_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "continuous_trait_values", :force => true do |t|
    t.integer  "otu_id"
    t.integer  "continuous_trait_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.float    "value"
  end

  create_table "continuous_traits", :force => true do |t|
    t.string   "name"
    t.integer  "import_job_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "csv_datasets", :force => true do |t|
    t.string   "csv_file_file_name"
    t.string   "csv_file_content_type"
    t.integer  "csv_file_file_size"
    t.datetime "csv_file_updated_at"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "iczn_groups", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "import_jobs", :force => true do |t|
    t.integer  "csv_dataset_id"
    t.string   "state",                     :limit => 25, :default => "new", :null => false
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.string   "quantitative_header_start"
    t.string   "quantitative_header_end"
    t.string   "qualitative_header_start"
    t.string   "qualitative_header_end"
    t.integer  "csv_row_count"
  end

  create_table "otus", :force => true do |t|
    t.string   "name"
    t.string   "author"
    t.integer  "taxon_id"
    t.integer  "import_job_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "parse_issues", :force => true do |t|
    t.integer  "import_job_id"
    t.integer  "row_location",       :null => false
    t.integer  "column_location",    :null => false
    t.string   "column_name"
    t.string   "issue_description",  :null => false
    t.string   "suggested_solution", :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "row_name"
  end

  add_index "parse_issues", ["column_location"], :name => "index_import_issues_on_column_location"
  add_index "parse_issues", ["row_location"], :name => "index_import_issues_on_row_location"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  add_index "projects_users", ["project_id", "user_id"], :name => "index_projects_users_on_project_id_and_user_id"
  add_index "projects_users", ["user_id", "project_id"], :name => "index_projects_users_on_user_id_and_project_id"

  create_table "taxa", :force => true do |t|
    t.string   "name"
    t.string   "uri"
    t.integer  "iczn_group_id"
    t.integer  "import_job_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "taxon_ancestors", :force => true do |t|
    t.integer  "parent_id",  :null => false
    t.integer  "child_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "taxon_ancestors", ["parent_id", "child_id"], :name => "index_taxon_ancestors_on_parent_id_and_child_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "validation_issues", :force => true do |t|
    t.integer  "import_job_id"
    t.string   "column_name"
    t.string   "issue_description",  :null => false
    t.string   "suggested_solution", :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "column_location"
  end

  add_index "validation_issues", ["column_location"], :name => "index_validation_issues_on_column_location"

end
