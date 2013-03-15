class CreateValidationIssues < ActiveRecord::Migration
  def change
    create_table :validation_issues do |t|
      t.references :import_job
      t.integer :row_location, :null => false
      t.integer :column_location, :null => false
      t.string :column_name
      t.string :issue_description, :null => false
      t.string :suggested_solution, :null => false
      t.timestamps
    end
    add_index :validation_issues, :row_location
    add_index :validation_issues, :column_location
  end
end
