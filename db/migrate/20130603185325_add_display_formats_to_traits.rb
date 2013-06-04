class AddDisplayFormatsToTraits < ActiveRecord::Migration
  def change
    change_table :continuous_traits do |t|
      t.references :display_format
    end
    add_index :continuous_traits, :display_format_id
    change_table :categorical_traits do |t|
      t.references :display_format
    end
    add_index :categorical_traits, :display_format_id
  end
end
