class CategoricalTrait < ActiveRecord::Base
  attr_accessible :name
  has_many :categorical_trait_categories, :dependent => :destroy
  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  scope :sorted, order('name ASC')

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end
end
