class RemoveFieldsFromValidationIssues < ActiveRecord::Migration
  def up
    remove_index :validation_issues, :row_location
    remove_column :validation_issues, :row_location
    change_column :validation_issues, :column_location, :integer, :null => true
  end
  def down
    add_column :validation_issues, :row_location, :integer, :null => false
    change_column :validation_issues, :column_location, :integer, :null => false
    add_index :validation_issues, :row_location
    add_index :validation_issues, :column_location
  end
end
