class CreateCategoricalTraitCategories < ActiveRecord::Migration
  def change
    create_table :categorical_trait_categories do |t|
      t.string :name
      t.references :categorical_trait
      t.timestamps
    end
  end
end
