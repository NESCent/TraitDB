class ChangeParseAndValidationIssueStringsToText < ActiveRecord::Migration
  def up
    [:parse_issues, :validation_issues].each do |column|
      change_column column, :column_name, :text
      change_column column, :issue_description, :text
      change_column column, :suggested_solution, :text
    end
    change_column :parse_issues, :row_name, :text

  end
  def down
    [:parse_issues, :validation_issues].each do |column|
      change_column column, :column_name, :string
      change_column column, :issue_description, :string
      change_column column, :suggested_solution, :string
    end
    change_column :parse_issues, :row_name, :string
  end
end
