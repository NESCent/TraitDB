class AddValueToContinuousTraitValues < ActiveRecord::Migration
  def change
    add_column :continuous_trait_values, :value, :float
  end
end
