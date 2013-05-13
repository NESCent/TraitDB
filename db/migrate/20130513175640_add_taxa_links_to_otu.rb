class AddTaxaLinksToOtu < ActiveRecord::Migration
  def up
    change_table :otus do |t|
      t.rename :taxon_id, :species_taxon_id
      t.integer :genus_taxon_id, :references => :taxa
      t.integer :family_taxon_id, :references => :taxa
      t.integer :order_taxon_id, :references => :taxa
      t.integer :htg_taxon_id, :references => :taxa
    end
    add_index :otus, :genus_taxon_id
    add_index :otus, :family_taxon_id
    add_index :otus, :order_taxon_id
    add_index :otus, :htg_taxon_id
    Otu.all.each do |otu|
      otu.genus_taxon_id = otu.species_taxon.parent.id
      otu.family_taxon_id = otu.genus_taxon.parent.id
      otu.order_taxon_id = otu.family_taxon.parent.id
      otu.htg_taxon_id = otu.order_taxon.parent.id
      otu.save
    end
  end
  def down
    remove_index :otus, :genus_taxon_id
    remove_index :otus, :family_taxon_id
    remove_index :otus, :order_taxon_id
    remove_index :otus, :htg_taxon_id
    change_table :otus do |t|
      t.rename :species_taxon_id, :taxon_id
      t.remove :genus_taxon_id
      t.remove :family_taxon_id
      t.remove :order_taxon_id
      t.remove :htg_taxon_id
    end

  end
end
