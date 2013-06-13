class CategoricalTrait < ActiveRecord::Base
  attr_accessible :name, :display_format_id
  has_many :categorical_trait_categories, :dependent => :destroy
  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  has_many :otus, :through => :categorical_trait_categories, :source => :categorical_trait_values
  belongs_to :display_format
  has_many :categorical_trait_notes
  has_and_belongs_to_many :trait_groups
  scope :sorted, order('name ASC')

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end
end
