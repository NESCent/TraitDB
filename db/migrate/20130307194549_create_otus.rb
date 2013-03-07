class CreateOtus < ActiveRecord::Migration
  def change
    create_table :otus do |t|
      t.string :name
      t.string :author
      t.references :taxon
      t.references :import_job
      t.timestamps
    end
  end
end
