class CreateCategoricalTraitValues < ActiveRecord::Migration
  def change
    create_table :categorical_trait_values do |t|
      t.integer :position
      t.references :otu
      t.references :categorical_trait
      t.references :categorical_trait_category
      t.timestamps
    end
  end
end
