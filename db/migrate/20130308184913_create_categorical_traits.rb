class CreateCategoricalTraits < ActiveRecord::Migration
  def change
    create_table :categorical_traits do |t|
      t.string :name
      t.references :import_job
      t.timestamps
    end
  end
end
