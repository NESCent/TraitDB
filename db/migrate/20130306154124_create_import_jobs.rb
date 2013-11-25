class CreateImportJobs < ActiveRecord::Migration
  def change
    create_table :import_jobs do |t|
      t.references :csv_dataset
      t.string :status, :limit => 25, :null => false, :default => "new"
      t.timestamps
    end
  end
end
