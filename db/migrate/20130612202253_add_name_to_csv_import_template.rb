class AddNameToCsvImportTemplate < ActiveRecord::Migration
  def change
    change_table :csv_import_templates do |t|
      t.string :name
    end
  end
end
