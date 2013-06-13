class CreateOtuMetadataFields < ActiveRecord::Migration
  def change
    create_table :otu_metadata_fields do |t|
      t.string :name
      t.timestamps
    end
    add_index :otu_metadata_fields, :name
  end
end
