class RenameCsvImportTemplateToCsvImportConfig < ActiveRecord::Migration
  def up
    rename_table :csv_import_templates, :csv_import_configs
    rename_column :csv_import_configs, "template_file_file_name", "config_file_file_name"
    rename_column :csv_import_configs, "template_file_content_type", "config_file_content_type"
    rename_column :csv_import_configs, "template_file_file_size", "config_file_file_size"
    rename_column :csv_import_configs, "template_file_updated_at", "config_file_updated_at"
    rename_column :import_jobs, "csv_import_template_id", "csv_import_config_id"
  end

  def down
    rename_table :csv_import_configs, :csv_import_templates
    rename_column :csv_import_templates, "config_file_file_name", "template_file_file_name"
    rename_column :csv_import_templates, "config_file_content_type", "template_file_content_type"
    rename_column :csv_import_templates, "config_file_file_size", "template_file_file_size"
    rename_column :csv_import_templates, "config_file_updated_at", "template_file_updated_at"
    rename_column :import_jobs, "csv_import_config_id", "csv_import_template_id"
  end
end
