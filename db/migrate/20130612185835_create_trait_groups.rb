class CreateTraitGroups < ActiveRecord::Migration
  def change
    create_table :trait_groups do |t|
      t.string :name
      t.timestamps
    end
    create_table :continuous_traits_trait_groups do |t|
      t.integer :continuous_trait_id
      t.integer :trait_group_id
    end
    create_table :categorical_traits_trait_groups do |t|
      t.integer :categorical_trait_id
      t.integer :trait_group_id
    end
    add_index :continuous_traits_trait_groups, :continuous_trait_id
    add_index :continuous_traits_trait_groups, :trait_group_id
    add_index :categorical_traits_trait_groups, :categorical_trait_id
    add_index :categorical_traits_trait_groups, :trait_group_id
  end
end
