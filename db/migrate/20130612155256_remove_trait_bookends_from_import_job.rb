class RemoveTraitBookendsFromImportJob < ActiveRecord::Migration
  def up
    change_table :import_jobs do |t|
      t.remove :quantitative_header_start_id
      t.remove :quantitative_header_end_id
      t.remove :qualitative_header_start_id
      t.remove :qualitative_header_end_id
    end
  end

  def down
    change_table :import_jobs do |t|
      t.integer :quantitative_header_start_id, :references => :headers
      t.integer :quantitative_header_end_id, :references => :headers
      t.integer :qualitative_header_start_id, :references => :headers
      t.integer :qualitative_header_end_id, :references => :headers
    end
    add_index :import_jobs, :quantitative_header_start_id
    add_index :import_jobs, :quantitative_header_end_id
    add_index :import_jobs, :qualitative_header_start_id
    add_index :import_jobs, :qualitative_header_end_id
  end
end
