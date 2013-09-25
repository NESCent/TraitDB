class CreateCsvImportTemplates < ActiveRecord::Migration
  def up
    create_table :csv_import_templates do |t|
      t.attachment :config_file
      t.references :project
      t.references :user
      t.timestamps
    end
    change_table :import_jobs do |t|
      t.references :csv_import_template
    end
  end
  def down
    drop_table :csv_import_templates
    remove_column :import_jobs, :csv_import_template_id
  end
end
