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

ActiveRecord::Schema.define(:version => 20130618201601) do

  create_table "categorical_trait_categories", :force => true do |t|
    t.string   "name"
    t.integer  "categorical_trait_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "categorical_trait_categories", ["categorical_trait_id"], :name => "index_categorical_trait_categories_on_categorical_trait_id"

  create_table "categorical_trait_notes", :force => true do |t|
    t.text     "notes"
    t.integer  "otu_id"
    t.integer  "categorical_trait_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "categorical_trait_notes", ["categorical_trait_id"], :name => "index_categorical_trait_notes_on_categorical_trait_id"
  add_index "categorical_trait_notes", ["otu_id"], :name => "index_categorical_trait_notes_on_otu_id"

  create_table "categorical_trait_values", :force => true do |t|
    t.integer  "position"
    t.integer  "otu_id"
    t.integer  "categorical_trait_id"
    t.integer  "categorical_trait_category_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "source_reference_id"
  end

  add_index "categorical_trait_values", ["categorical_trait_category_id"], :name => "index_categorical_trait_values_on_categorical_trait_category_id"
  add_index "categorical_trait_values", ["categorical_trait_id"], :name => "index_categorical_trait_values_on_categorical_trait_id"
  add_index "categorical_trait_values", ["otu_id"], :name => "index_categorical_trait_values_on_otu_id"
  add_index "categorical_trait_values", ["source_reference_id"], :name => "index_categorical_trait_values_on_source_reference_id"

  create_table "categorical_traits", :force => true do |t|
    t.string   "name"
    t.integer  "import_job_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "display_format_id"
  end

  add_index "categorical_traits", ["display_format_id"], :name => "index_categorical_traits_on_display_format_id"
  add_index "categorical_traits", ["import_job_id"], :name => "index_categorical_traits_on_import_job_id"
  add_index "categorical_traits", ["name"], :name => "index_categorical_traits_on_name"

  create_table "categorical_traits_trait_groups", :force => true do |t|
    t.integer "categorical_trait_id"
    t.integer "trait_group_id"
  end

  add_index "categorical_traits_trait_groups", ["categorical_trait_id"], :name => "index_categorical_traits_trait_groups_on_categorical_trait_id"
  add_index "categorical_traits_trait_groups", ["trait_group_id"], :name => "index_categorical_traits_trait_groups_on_trait_group_id"

  create_table "continuous_trait_notes", :force => true do |t|
    t.text     "notes"
    t.integer  "otu_id"
    t.integer  "continuous_trait_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "continuous_trait_notes", ["continuous_trait_id"], :name => "index_continuous_trait_notes_on_continuous_trait_id"
  add_index "continuous_trait_notes", ["otu_id"], :name => "index_continuous_trait_notes_on_otu_id"

  create_table "continuous_trait_values", :force => true do |t|
    t.integer  "otu_id"
    t.integer  "continuous_trait_id"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.decimal  "value",               :precision => 10, :scale => 2
    t.integer  "source_reference_id"
  end

  add_index "continuous_trait_values", ["continuous_trait_id"], :name => "index_continuous_trait_values_on_continuous_trait_id"
  add_index "continuous_trait_values", ["otu_id"], :name => "index_continuous_trait_values_on_otu_id"
  add_index "continuous_trait_values", ["source_reference_id"], :name => "index_continuous_trait_values_on_source_reference_id"

  create_table "continuous_traits", :force => true do |t|
    t.string   "name"
    t.integer  "import_job_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "display_format_id"
  end

  add_index "continuous_traits", ["display_format_id"], :name => "index_continuous_traits_on_display_format_id"
  add_index "continuous_traits", ["import_job_id"], :name => "index_continuous_traits_on_import_job_id"
  add_index "continuous_traits", ["name"], :name => "index_continuous_traits_on_name"

  create_table "continuous_traits_trait_groups", :force => true do |t|
    t.integer "continuous_trait_id"
    t.integer "trait_group_id"
  end

  add_index "continuous_traits_trait_groups", ["continuous_trait_id"], :name => "index_continuous_traits_trait_groups_on_continuous_trait_id"
  add_index "continuous_traits_trait_groups", ["trait_group_id"], :name => "index_continuous_traits_trait_groups_on_trait_group_id"

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

  add_index "csv_datasets", ["user_id"], :name => "index_csv_datasets_on_user_id"

  create_table "csv_import_templates", :force => true do |t|
    t.string   "template_file_file_name"
    t.string   "template_file_content_type"
    t.integer  "template_file_file_size"
    t.datetime "template_file_updated_at"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "name"
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

  create_table "display_formats", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "headers", :force => true do |t|
    t.string   "column_name"
    t.integer  "import_job_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "headers", ["column_name"], :name => "index_headers_on_column_name"
  add_index "headers", ["import_job_id"], :name => "index_headers_on_import_job_id"

  create_table "iczn_groups", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "iczn_groups", ["name"], :name => "index_iczn_groups_on_name"

  create_table "import_jobs", :force => true do |t|
    t.integer  "csv_dataset_id"
    t.string   "state",                  :limit => 25, :default => "new", :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.integer  "csv_row_count"
    t.integer  "csv_import_template_id"
  end

  add_index "import_jobs", ["csv_dataset_id"], :name => "index_import_jobs_on_csv_dataset_id"

  create_table "otu_metadata_fields", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "otu_metadata_fields", ["name"], :name => "index_otu_metadata_fields_on_name"

  create_table "otu_metadata_values", :force => true do |t|
    t.text     "value"
    t.integer  "otu_metadata_field_id"
    t.integer  "otu_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "otu_metadata_values", ["otu_id"], :name => "index_otu_metadata_values_on_otu_id"
  add_index "otu_metadata_values", ["otu_metadata_field_id"], :name => "index_otu_metadata_values_on_otu_metadata_field_id"

  create_table "otus", :force => true do |t|
    t.string   "author"
    t.integer  "species_taxon_id"
    t.integer  "import_job_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "notes"
    t.integer  "genus_taxon_id"
    t.integer  "family_taxon_id"
    t.integer  "order_taxon_id"
    t.integer  "htg_taxon_id"
  end

  add_index "otus", ["family_taxon_id"], :name => "index_otus_on_family_taxon_id"
  add_index "otus", ["genus_taxon_id"], :name => "index_otus_on_genus_taxon_id"
  add_index "otus", ["htg_taxon_id"], :name => "index_otus_on_htg_taxon_id"
  add_index "otus", ["import_job_id"], :name => "index_otus_on_import_job_id"
  add_index "otus", ["order_taxon_id"], :name => "index_otus_on_order_taxon_id"
  add_index "otus", ["species_taxon_id"], :name => "index_otus_on_taxon_id"

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
  add_index "parse_issues", ["import_job_id"], :name => "index_parse_issues_on_import_job_id"
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

  create_table "source_references", :force => true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.integer  "year"
    t.string   "title"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "source_references", ["last_name", "first_name", "year", "title", "url"], :name => "by_ln_fn_year_title_url"
  add_index "source_references", ["title"], :name => "index_source_references_on_title"
  add_index "source_references", ["url"], :name => "index_source_references_on_url"

  create_table "taxa", :force => true do |t|
    t.string   "name"
    t.string   "uri"
    t.integer  "iczn_group_id"
    t.integer  "import_job_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "taxa", ["iczn_group_id"], :name => "index_taxa_on_iczn_group_id"
  add_index "taxa", ["import_job_id"], :name => "index_taxa_on_import_job_id"
  add_index "taxa", ["name"], :name => "index_taxa_on_name"

  create_table "taxa_trait_groups", :force => true do |t|
    t.integer "taxon_id"
    t.integer "trait_group_id"
  end

  add_index "taxa_trait_groups", ["taxon_id"], :name => "index_taxa_trait_groups_on_taxon_id"
  add_index "taxa_trait_groups", ["trait_group_id"], :name => "index_taxa_trait_groups_on_trait_group_id"

  create_table "taxon_ancestors", :force => true do |t|
    t.integer  "parent_id",  :null => false
    t.integer  "child_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "taxon_ancestors", ["parent_id", "child_id"], :name => "index_taxon_ancestors_on_parent_id_and_child_id"

  create_table "trait_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "admin",                  :default => false
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
  add_index "validation_issues", ["import_job_id"], :name => "index_validation_issues_on_import_job_id"

end
