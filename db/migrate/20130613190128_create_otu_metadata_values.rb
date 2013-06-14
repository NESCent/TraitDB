class CreateOtuMetadataValues < ActiveRecord::Migration
  def change
    create_table :otu_metadata_values do |t|
      t.text :value
      t.references :otu_metadata_field
      t.references :otu
      t.timestamps
    end
    add_index :otu_metadata_values, :otu_id
    add_index :otu_metadata_values, :otu_metadata_field_id
  end
end
