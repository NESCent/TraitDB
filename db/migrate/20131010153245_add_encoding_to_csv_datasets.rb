class AddEncodingToCsvDatasets < ActiveRecord::Migration
  def change
    add_column :csv_datasets, :encoding, :string
  end
end
