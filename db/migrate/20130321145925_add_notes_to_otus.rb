class AddNotesToOtus < ActiveRecord::Migration
  def change
    add_column :otus, :notes, :text
  end
end
