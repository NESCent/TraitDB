class CreateHeaders < ActiveRecord::Migration
  def change
    create_table :headers do |t|
      t.string :column_name
      t.references :import_job
      t.timestamps
    end
  end
end
