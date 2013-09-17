class AddNameColumnsToOtu < ActiveRecord::Migration
  def change
    add_column :otus, :name, :string
    add_column :otus, :sort_name, :string
    Otu.all.each do |otu|
      otu.update_names(nil)
      otu.save
    end
  end
end
