class AddHeaderBookendsToImportJob < ActiveRecord::Migration
  def change
    add_column :import_jobs, :quantitative_header_start, :string
    add_column :import_jobs, :quantitative_header_end, :string
    add_column :import_jobs, :qualitative_header_start, :string
    add_column :import_jobs, :qualitative_header_end, :string
  end
end
