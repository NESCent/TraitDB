class CreateTaxonAncestors < ActiveRecord::Migration
  def change
    create_table :taxon_ancestors do |t|
      t.integer :parent_id, :null => false
      t.integer :child_id, :null => false
  	  t.timestamps
  	end
    add_index :taxon_ancestors, ['parent_id','child_id']
  end
end
