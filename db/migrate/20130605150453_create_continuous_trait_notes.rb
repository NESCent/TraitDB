class CreateContinuousTraitNotes < ActiveRecord::Migration
  def change
    create_table :continuous_trait_notes do |t|
      t.text :notes
      t.references :otu
      t.references :continuous_trait
      t.timestamps
    end
    add_index :continuous_trait_notes, :otu_id
    add_index :continuous_trait_notes, :continuous_trait_id
  end
end
