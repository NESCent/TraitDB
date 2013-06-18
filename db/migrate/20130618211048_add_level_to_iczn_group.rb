class AddLevelToIcznGroup < ActiveRecord::Migration
  def change
    add_column :iczn_groups, :level, :integer
  end
end
