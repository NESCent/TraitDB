class AddNameColumnsToOtu < ActiveRecord::Migration
  def change
    add_column :otus, :name, :string
    add_column :otus, :sort_name, :string
  end
end
