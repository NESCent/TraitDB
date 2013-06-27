class AddTraitGroupTaxaRelationship < ActiveRecord::Migration
  def change
    create_table :taxa_trait_groups do |t|
      t.integer :taxon_id
      t.integer :trait_group_id
    end
    add_index :taxa_trait_groups, :taxon_id
    add_index :taxa_trait_groups, :trait_group_id
  end
end
