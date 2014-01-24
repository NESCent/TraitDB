class AddPositionToContinuousTraitValue < ActiveRecord::Migration
  def change
    add_column :continuous_trait_values, 'position', :integer
  end
end
