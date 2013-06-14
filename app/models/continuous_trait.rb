class ContinuousTrait < ActiveRecord::Base
  attr_accessible :name, :display_format_id
  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  has_many :continuous_trait_values
  has_many :otus, :through => :continuous_trait_values
  belongs_to :display_format
  has_many :continuous_trait_notes
  has_and_belongs_to_many :trait_groups

  scope :sorted, order('name ASC')

  def display_format_name
    if display_format
      display_format.name
    else
      'Default'
    end
  end

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end
end
