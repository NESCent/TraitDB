class Otu < ActiveRecord::Base
  attr_accessible :author, :name, :taxon, :import_job
  belongs_to :taxon
  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  scope :sorted, order('name ASC')

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end
end
