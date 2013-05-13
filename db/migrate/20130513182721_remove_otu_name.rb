class RemoveOtuName < ActiveRecord::Migration
  def up
    remove_column :otus, :name
  end
  def down
    add_column :otus, :name, :string
  end
end
