class CreateContinuousTraits < ActiveRecord::Migration
  def change
    create_table :continuous_traits do |t|
      t.string :name
      t.references :import_job
      t.timestamps
    end
  end
end
