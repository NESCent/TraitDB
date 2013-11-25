class AddCsvRowCountToImportJobs < ActiveRecord::Migration
  def change
    add_column :import_jobs, :csv_row_count, :integer
  end
end
