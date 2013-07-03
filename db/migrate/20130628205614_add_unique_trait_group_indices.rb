class AddUniqueTraitGroupIndices < ActiveRecord::Migration
  def change
    add_index :categorical_traits_trait_groups, [:categorical_trait_id, :trait_group_id], :unique => true, :name => 'by_categorical_trait_and_trait_group'
    add_index :continuous_traits_trait_groups, [:continuous_trait_id, :trait_group_id], :unique => true, :name => 'by_continuous_trait_and_trait_group'
  end
end
