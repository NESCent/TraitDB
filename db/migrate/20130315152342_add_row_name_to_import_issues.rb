class AddRowNameToImportIssues < ActiveRecord::Migration
  def change
    add_column :import_issues, :row_name, :string
  end
end
