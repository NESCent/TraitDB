module TraitCommon
  extend ActiveSupport::Concern
  included do
    attr_accessible :name, :display_format_id
    belongs_to :project
    belongs_to :import_job
    has_one :csv_dataset, :through => :import_job
    belongs_to :display_format
    has_and_belongs_to_many :trait_groups
    belongs_to :trait_set
    scope :by_project, lambda{|p| where(:project_id => p) unless p.nil?}
    scope :sorted, -> { order('name ASC') }
  end

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end

  def full_name
    return "#{trait_set.full_name}: #{name}" if trait_set
    return name
  end

end