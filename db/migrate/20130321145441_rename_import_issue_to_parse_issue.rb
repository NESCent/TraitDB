class RenameImportIssueToParseIssue < ActiveRecord::Migration
  def up
    rename_table :import_issues, :parse_issues
  end

  def down
    rename_table :parse_issues, :import_issues
  end
end
