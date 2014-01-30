class AddIcznAndProjectIndexToTaxa < ActiveRecord::Migration
  def change
    add_index :taxa, [:iczn_group_id, :project_id], :name => 'taxa_by_ig_and_project'
  end
end
