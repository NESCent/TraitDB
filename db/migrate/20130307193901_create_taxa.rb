class CreateTaxa < ActiveRecord::Migration
  def change
    create_table :taxa do |t|
      t.string :name
      t.string :uri
      t.references :iczn_group
      t.references :import_job
      t.timestamps
    end
  end
end
