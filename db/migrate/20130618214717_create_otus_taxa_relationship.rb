class CreateOtusTaxaRelationship < ActiveRecord::Migration
  def up
    create_table :otus_taxa do |t|
      t.integer :otu_id
      t.integer :taxon_id
    end
    remove_column :otus, :species_taxon_id
    remove_column :otus, :genus_taxon_id
    remove_column :otus, :order_taxon_id
    remove_column :otus, :family_taxon_id
    remove_column :otus, :htg_taxon_id
  end
  def down
    drop_table :otus_taxa
    add_column :otus, :species_taxon_id, :integer
    add_column :otus, :genus_taxon_id, :integer
    add_column :otus, :order_taxon_id, :integer
    add_column :otus, :family_taxon_id, :integer
    add_column :otus, :htg_taxon_id, :integer
    add_index :otus, :species_taxon_id
    add_index :otus, :genus_taxon_id
    add_index :otus, :order_taxon_id
    add_index :otus, :family_taxon_id
    add_index :otus, :htg_taxon_id
  end
end
