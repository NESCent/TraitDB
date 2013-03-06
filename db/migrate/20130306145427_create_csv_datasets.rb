class CreateCsvDatasets < ActiveRecord::Migration
  def change
    create_table :csv_datasets do |t|
      t.attachment :csv_file
      t.references :project
      t.references :user
      t.timestamps
    end
  end
end
