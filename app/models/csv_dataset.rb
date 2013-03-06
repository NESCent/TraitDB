class CsvDataset < ActiveRecord::Base
  attr_accessible :csv_file
  has_attached_file :csv_file
  belongs_to :project
  belongs_to :user
  has_many :import_jobs
  
  @@fields = ["chromosome number (female)","c-value","predicted ploidy (1n, 2n, 3n, 4n)","molecular basis (dosage, Y dominant, W dominant)","gametophytic chromosome number (minimum)","sporophytic chromosome number (mean)","Hybrid (no, yes)","molecular basis (dosage, Y dominant, W dominant, DM-W)"]
  def self.fields
    @@fields
  end
end
