class RefactorImportStatus < ActiveRecord::Migration
  def change
    rename_column :import_jobs, :status, :state
  end
end
