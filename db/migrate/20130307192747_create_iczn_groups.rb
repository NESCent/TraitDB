class CreateIcznGroups < ActiveRecord::Migration
  def change
    create_table :iczn_groups do |t|
      t.string :name, :null => false
      t.timestamps
    end
  end
end
