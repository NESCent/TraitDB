class CreateCategoricalTraitNotes < ActiveRecord::Migration
  def change
    create_table :categorical_trait_notes do |t|
      t.text :notes
      t.references :otu
      t.references :categorical_trait
      t.timestamps
    end
    add_index :categorical_trait_notes, :otu_id
    add_index :categorical_trait_notes, :categorical_trait_id
  end
end
