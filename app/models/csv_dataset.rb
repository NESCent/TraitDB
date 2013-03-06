class CsvDataset < ActiveRecord::Base
  attr_accessible :csv_file
  has_attached_file :csv_file
  belongs_to :project
  belongs_to :user
  has_many :import_jobs
end
