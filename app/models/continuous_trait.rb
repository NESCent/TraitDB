class ContinuousTrait < ActiveRecord::Base
  attr_accessible :name
  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  has_many :continuous_trait_values
  has_many :otus, :through => :continuous_trait_values

  scope :sorted, order('name ASC')

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end
end
