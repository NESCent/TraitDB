class CreateContinuousTraitValues < ActiveRecord::Migration
  def change
    create_table :continuous_trait_values do |t|
      t.integer :position
      t.references :otu
      t.references :continuous_trait
      t.float
      t.timestamps
    end
  end
end
