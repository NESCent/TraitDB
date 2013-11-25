class AddSourceReferencesToTraitValues < ActiveRecord::Migration
  def change
    add_column :continuous_trait_values, :source_reference_id, :integer, :references => 'source_references'
    add_column :categorical_trait_values, :source_reference_id, :integer, :references => 'source_references'
  end
end
