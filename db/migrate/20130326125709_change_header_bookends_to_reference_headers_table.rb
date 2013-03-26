class ChangeHeaderBookendsToReferenceHeadersTable < ActiveRecord::Migration
  def up
    change_table :import_jobs do |t|
      t.integer :quantitative_header_start_id, :references => :headers
      t.integer :quantitative_header_end_id, :references => :headers
      t.integer :qualitative_header_start_id, :references => :headers
      t.integer :qualitative_header_end_id, :references => :headers
      t.remove :quantitative_header_start
      t.remove :quantitative_header_end
      t.remove :qualitative_header_start
      t.remove :qualitative_header_end
    end
    add_index :import_jobs, :quantitative_header_start_id
    add_index :import_jobs, :quantitative_header_end_id
    add_index :import_jobs, :qualitative_header_start_id
    add_index :import_jobs, :qualitative_header_end_id
  end
  def down
    change_table :import_jobs do |t|
      t.remove :quantitative_header_start_id
      t.remove :quantitative_header_end_id
      t.remove :qualitative_header_start_id
      t.remove :qualitative_header_end_id
      t.string :quantitative_header_start
      t.string :quantitative_header_end
      t.string :qualitative_header_start
      t.string :qualitative_header_end
    end
  end
end
