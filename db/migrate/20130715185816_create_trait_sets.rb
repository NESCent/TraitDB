class CreateTraitSets < ActiveRecord::Migration
  def up
    create_table :trait_sets do |t|
      t.string :name
      t.integer :level, :default => 0
      t.belongs_to :parent_trait_set
      t.timestamps
    end
    add_index :trait_sets, :parent_trait_set_id
    change_table :categorical_traits do |t|
      t.references :trait_set
    end
    add_index :categorical_traits, :trait_set_id
    change_table :continuous_traits do |t|
      t.references :trait_set
    end
    add_index :continuous_traits, :trait_set_id
  end
  def down
    remove_index :trait_sets, :parent_trait_set_id
    drop_table :trait_sets

    remove_index :continuous_traits, :trait_set_id
    remove_column :continuous_traits, :trait_set_id

    remove_index :categorical_traits, :trait_set_id
    remove_column :categorical_traits, :trait_set_id
  end
end
