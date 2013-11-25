class ChangeContinuousTraitValuesValueToDecimal < ActiveRecord::Migration
  def up
    change_column :continuous_trait_values, :value, :decimal, {:precision => 10, :scale => 2}
  end

  def down
    change_column :continuous_trait_values, :value, :float
  end
end
