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

ActiveRecord::Schema.define(version: 20140130193724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categorical_trait_categories", force: true do |t|
    t.string   "name"
    t.integer  "categorical_trait_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categorical_trait_categories", ["categorical_trait_id"], name: "index_categorical_trait_categories_on_categorical_trait_id", using: :btree

  create_table "categorical_trait_notes", force: true do |t|
    t.text     "notes"
    t.integer  "otu_id"
    t.integer  "categorical_trait_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categorical_trait_notes", ["categorical_trait_id"], name: "index_categorical_trait_notes_on_categorical_trait_id", using: :btree
  add_index "categorical_trait_notes", ["otu_id"], name: "index_categorical_trait_notes_on_otu_id", using: :btree

  create_table "categorical_trait_values", force: true do |t|
    t.integer  "position"
    t.integer  "otu_id"
    t.integer  "categorical_trait_id"
    t.integer  "categorical_trait_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_reference_id"
  end

  add_index "categorical_trait_values", ["categorical_trait_category_id"], name: "index_categorical_trait_values_on_categorical_trait_category_id", using: :btree
  add_index "categorical_trait_values", ["categorical_trait_id"], name: "index_categorical_trait_values_on_categorical_trait_id", using: :btree
  add_index "categorical_trait_values", ["otu_id"], name: "index_categorical_trait_values_on_otu_id", using: :btree
  add_index "categorical_trait_values", ["source_reference_id"], name: "index_categorical_trait_values_on_source_reference_id", using: :btree

  create_table "categorical_traits", force: true do |t|
    t.string   "name"
    t.integer  "import_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_format_id"
    t.integer  "trait_set_id"
    t.integer  "project_id",        default: 1, null: false
  end

  add_index "categorical_traits", ["display_format_id"], name: "index_categorical_traits_on_display_format_id", using: :btree
  add_index "categorical_traits", ["import_job_id"], name: "index_categorical_traits_on_import_job_id", using: :btree
  add_index "categorical_traits", ["name"], name: "index_categorical_traits_on_name", using: :btree
  add_index "categorical_traits", ["project_id"], name: "index_categorical_traits_on_project_id", using: :btree
  add_index "categorical_traits", ["trait_set_id"], name: "index_categorical_traits_on_trait_set_id", using: :btree

  create_table "categorical_traits_trait_groups", force: true do |t|
    t.integer "categorical_trait_id"
    t.integer "trait_group_id"
  end

  add_index "categorical_traits_trait_groups", ["categorical_trait_id", "trait_group_id"], name: "by_categorical_trait_and_trait_group", unique: true, using: :btree
  add_index "categorical_traits_trait_groups", ["categorical_trait_id"], name: "index_categorical_traits_trait_groups_on_categorical_trait_id", using: :btree
  add_index "categorical_traits_trait_groups", ["trait_group_id"], name: "index_categorical_traits_trait_groups_on_trait_group_id", using: :btree

  create_table "continuous_trait_notes", force: true do |t|
    t.text     "notes"
    t.integer  "otu_id"
    t.integer  "continuous_trait_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "continuous_trait_notes", ["continuous_trait_id"], name: "index_continuous_trait_notes_on_continuous_trait_id", using: :btree
  add_index "continuous_trait_notes", ["otu_id"], name: "index_continuous_trait_notes_on_otu_id", using: :btree

  create_table "continuous_trait_values", force: true do |t|
    t.integer  "otu_id"
    t.integer  "continuous_trait_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "value",               precision: 20, scale: 3
    t.integer  "source_reference_id"
    t.integer  "position"
  end

  add_index "continuous_trait_values", ["continuous_trait_id"], name: "index_continuous_trait_values_on_continuous_trait_id", using: :btree
  add_index "continuous_trait_values", ["otu_id"], name: "index_continuous_trait_values_on_otu_id", using: :btree
  add_index "continuous_trait_values", ["source_reference_id"], name: "index_continuous_trait_values_on_source_reference_id", using: :btree

  create_table "continuous_traits", force: true do |t|
    t.string   "name"
    t.integer  "import_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_format_id"
    t.integer  "trait_set_id"
    t.integer  "project_id",        default: 1, null: false
  end

  add_index "continuous_traits", ["display_format_id"], name: "index_continuous_traits_on_display_format_id", using: :btree
  add_index "continuous_traits", ["import_job_id"], name: "index_continuous_traits_on_import_job_id", using: :btree
  add_index "continuous_traits", ["name"], name: "index_continuous_traits_on_name", using: :btree
  add_index "continuous_traits", ["project_id"], name: "index_continuous_traits_on_project_id", using: :btree
  add_index "continuous_traits", ["trait_set_id"], name: "index_continuous_traits_on_trait_set_id", using: :btree

  create_table "continuous_traits_trait_groups", force: true do |t|
    t.integer "continuous_trait_id"
    t.integer "trait_group_id"
  end

  add_index "continuous_traits_trait_groups", ["continuous_trait_id", "trait_group_id"], name: "by_continuous_trait_and_trait_group", unique: true, using: :btree
  add_index "continuous_traits_trait_groups", ["continuous_trait_id"], name: "index_continuous_traits_trait_groups_on_continuous_trait_id", using: :btree
  add_index "continuous_traits_trait_groups", ["trait_group_id"], name: "index_continuous_traits_trait_groups_on_trait_group_id", using: :btree

  create_table "csv_datasets", force: true do |t|
    t.string   "csv_file_file_name"
    t.string   "csv_file_content_type"
    t.integer  "csv_file_file_size"
    t.datetime "csv_file_updated_at"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encoding"
  end

  add_index "csv_datasets", ["user_id"], name: "index_csv_datasets_on_user_id", using: :btree

  create_table "csv_import_configs", force: true do |t|
    t.string   "config_file_file_name"
    t.string   "config_file_content_type"
    t.integer  "config_file_file_size"
    t.datetime "config_file_updated_at"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "display_formats", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "headers", force: true do |t|
    t.string   "column_name"
    t.integer  "import_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "headers", ["column_name"], name: "index_headers_on_column_name", using: :btree
  add_index "headers", ["import_job_id"], name: "index_headers_on_import_job_id", using: :btree

  create_table "iczn_groups", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level"
  end

  add_index "iczn_groups", ["name"], name: "index_iczn_groups_on_name", using: :btree

  create_table "iczn_groups_projects", force: true do |t|
    t.integer "iczn_group_id"
    t.integer "project_id"
  end

  add_index "iczn_groups_projects", ["iczn_group_id", "project_id"], name: "by_iczn_group_and_project", unique: true, using: :btree
  add_index "iczn_groups_projects", ["iczn_group_id"], name: "index_iczn_groups_projects_on_iczn_group_id", using: :btree
  add_index "iczn_groups_projects", ["project_id"], name: "index_iczn_groups_projects_on_project_id", using: :btree

  create_table "import_jobs", force: true do |t|
    t.integer  "csv_dataset_id"
    t.string   "state",                limit: 25, default: "new", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "csv_row_count"
    t.integer  "csv_import_config_id"
  end

  add_index "import_jobs", ["csv_dataset_id"], name: "index_import_jobs_on_csv_dataset_id", using: :btree

  create_table "otu_metadata_fields", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id", default: 1, null: false
  end

  add_index "otu_metadata_fields", ["name"], name: "index_otu_metadata_fields_on_name", using: :btree
  add_index "otu_metadata_fields", ["project_id"], name: "index_otu_metadata_fields_on_project_id", using: :btree

  create_table "otu_metadata_values", force: true do |t|
    t.text     "value"
    t.integer  "otu_metadata_field_id"
    t.integer  "otu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "otu_metadata_values", ["otu_id"], name: "index_otu_metadata_values_on_otu_id", using: :btree
  add_index "otu_metadata_values", ["otu_metadata_field_id"], name: "index_otu_metadata_values_on_otu_metadata_field_id", using: :btree

  create_table "otus", force: true do |t|
    t.string   "author"
    t.integer  "import_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.integer  "project_id",    default: 1, null: false
    t.string   "name"
    t.string   "sort_name"
  end

  add_index "otus", ["import_job_id"], name: "index_otus_on_import_job_id", using: :btree
  add_index "otus", ["project_id"], name: "index_otus_on_project_id", using: :btree

  create_table "otus_taxa", force: true do |t|
    t.integer "otu_id"
    t.integer "taxon_id"
  end

  add_index "otus_taxa", ["otu_id", "taxon_id"], name: "by_otu_and_taxon", using: :btree

  create_table "parse_issues", force: true do |t|
    t.integer  "import_job_id"
    t.integer  "row_location",       null: false
    t.integer  "column_location",    null: false
    t.string   "column_name"
    t.string   "issue_description",  null: false
    t.string   "suggested_solution", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "row_name"
  end

  add_index "parse_issues", ["column_location"], name: "index_parse_issues_on_column_location", using: :btree
  add_index "parse_issues", ["import_job_id"], name: "index_parse_issues_on_import_job_id", using: :btree
  add_index "parse_issues", ["row_location"], name: "index_parse_issues_on_row_location", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "summary_description"
    t.text     "detail_description"
    t.text     "url"
    t.text     "url_text"
  end

  create_table "projects_users", id: false, force: true do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  add_index "projects_users", ["project_id", "user_id"], name: "by_project_and_user", unique: true, using: :btree
  add_index "projects_users", ["project_id", "user_id"], name: "index_projects_users_on_project_id_and_user_id", using: :btree
  add_index "projects_users", ["user_id", "project_id"], name: "index_projects_users_on_user_id_and_project_id", using: :btree

  create_table "source_references", force: true do |t|
    t.text     "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id", default: 1, null: false
  end

  add_index "source_references", ["project_id"], name: "index_source_references_on_project_id", using: :btree
  add_index "source_references", ["source"], name: "index_source_references_on_source", using: :btree

  create_table "taxa", force: true do |t|
    t.string   "name"
    t.string   "uri"
    t.integer  "iczn_group_id"
    t.integer  "import_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",    default: 1, null: false
  end

  add_index "taxa", ["iczn_group_id", "project_id"], name: "taxa_by_ig_and_project", using: :btree
  add_index "taxa", ["iczn_group_id"], name: "index_taxa_on_iczn_group_id", using: :btree
  add_index "taxa", ["import_job_id"], name: "index_taxa_on_import_job_id", using: :btree
  add_index "taxa", ["name"], name: "index_taxa_on_name", using: :btree
  add_index "taxa", ["project_id"], name: "index_taxa_on_project_id", using: :btree

  create_table "taxa_trait_groups", force: true do |t|
    t.integer "taxon_id"
    t.integer "trait_group_id"
  end

  add_index "taxa_trait_groups", ["taxon_id", "trait_group_id"], name: "by_taxon_and_trait_group", unique: true, using: :btree
  add_index "taxa_trait_groups", ["taxon_id"], name: "index_taxa_trait_groups_on_taxon_id", using: :btree
  add_index "taxa_trait_groups", ["trait_group_id"], name: "index_taxa_trait_groups_on_trait_group_id", using: :btree

  create_table "taxon_ancestors", force: true do |t|
    t.integer  "parent_id",  null: false
    t.integer  "child_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taxon_ancestors", ["parent_id", "child_id"], name: "index_taxon_ancestors_on_parent_id_and_child_id", using: :btree

  create_table "trait_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id", default: 1, null: false
  end

  add_index "trait_groups", ["project_id"], name: "index_trait_groups_on_project_id", using: :btree

  create_table "trait_sets", force: true do |t|
    t.string   "name"
    t.integer  "level",               default: 0
    t.integer  "parent_trait_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",          default: 1, null: false
  end

  add_index "trait_sets", ["parent_trait_set_id"], name: "index_trait_sets_on_parent_trait_set_id", using: :btree
  add_index "trait_sets", ["project_id"], name: "index_trait_sets_on_project_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "validation_issues", force: true do |t|
    t.integer  "import_job_id"
    t.integer  "column_location"
    t.string   "column_name"
    t.string   "issue_description",  null: false
    t.string   "suggested_solution", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "validation_issues", ["column_location"], name: "index_validation_issues_on_column_location", using: :btree
  add_index "validation_issues", ["import_job_id"], name: "index_validation_issues_on_import_job_id", using: :btree

end
