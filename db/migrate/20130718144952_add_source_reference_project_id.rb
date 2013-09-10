class AddSourceReferenceProjectId < ActiveRecord::Migration
  def change
    add_column :source_references, :project_id, :integer, :null => false, :default => 1
    add_index :source_references, :project_id
  end
end
