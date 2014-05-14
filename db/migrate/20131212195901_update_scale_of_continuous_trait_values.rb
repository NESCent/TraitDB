class UpdateScaleOfContinuousTraitValues < ActiveRecord::Migration
  def change
    change_column :continuous_trait_values, :value, :decimal, {precision: 20, scale: 3}
  end
end
