class Otu < ActiveRecord::Base
  attr_accessible :author, :name, :taxon, :import_job
  belongs_to :taxon
  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  has_many :categorical_trait_values, :dependent => :destroy
  has_many :categorical_trait_categories, :through => :categorical_trait_values
  has_many :continuous_trait_values, :dependent => :destroy
  scope :sorted, order('name ASC')

  def categorical_traits
    categorical_trait_categories.map{|x| x.categorical_trait}.uniq
  end

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end
end
