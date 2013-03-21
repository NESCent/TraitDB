class CreateSourceReferences < ActiveRecord::Migration
  def change
    create_table :source_references do |t|
      t.string :last_name
      t.string :first_name
      t.integer :year
      t.string :title
      t.string :url
      t.timestamps
    end
  end
end
