class CreateContinuousTraitValues < ActiveRecord::Migration
  def change
    create_table :continuous_trait_values do |t|
      t.references :otu
      t.references :continuous_trait
      t.timestamps
    end
  end
end
