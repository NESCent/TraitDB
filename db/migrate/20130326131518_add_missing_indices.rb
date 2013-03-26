class AddMissingIndices < ActiveRecord::Migration
  def change
    add_index :categorical_trait_categories, :categorical_trait_id

    add_index :categorical_trait_values, :otu_id
    add_index :categorical_trait_values, :categorical_trait_id
    add_index :categorical_trait_values, :categorical_trait_category_id
    add_index :categorical_trait_values, :source_reference_id

    add_index :categorical_traits, :import_job_id
    add_index :categorical_traits, :name

    add_index :continuous_trait_values, :otu_id
    add_index :continuous_trait_values, :continuous_trait_id
    add_index :continuous_trait_values, :source_reference_id

    add_index :continuous_traits, :import_job_id
    add_index :continuous_traits, :name

    add_index :csv_datasets, :user_id

    add_index :headers, :column_name
    add_index :headers, :import_job_id

    add_index :iczn_groups, :name

    add_index :import_jobs, :csv_dataset_id

    add_index :otus, :name
    add_index :otus, :taxon_id
    add_index :otus, :import_job_id

    add_index :parse_issues, :import_job_id

    add_index :validation_issues, :import_job_id

    add_index :source_references, [:last_name, :first_name, :year, :title, :url], :name => 'by_ln_fn_year_title_url'
    add_index :source_references, :title
    add_index :source_references, :url

    add_index :taxa, :name
    add_index :taxa, :iczn_group_id
    add_index :taxa, :import_job_id
  end
end
