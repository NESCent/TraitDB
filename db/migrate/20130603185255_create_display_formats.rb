class CreateDisplayFormats < ActiveRecord::Migration
  def change
    create_table :display_formats do |t|
      t.string :name
      t.timestamps
    end
  end
end
