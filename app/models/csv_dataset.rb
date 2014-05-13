class CsvDataset < ActiveRecord::Base
  attr_accessible :csv_file
  attr_accessible :encoding
  has_attached_file :csv_file
  belongs_to :project
  belongs_to :user
  has_one :import_job, :dependent => :destroy
  validates_attachment_presence :csv_file
  validates_attachment_size :csv_file, :greater_than => 0.bytes, :unless => Proc.new { |imports| imports.csv_file_file_name.blank? }
  validates_attachment_content_type :csv_file, :content_type => 'text/csv'
  scope :by_project, lambda{|p| where(:project_id => p) unless p.nil?}

  def status
    return 'new' if import_job.nil?
    import_job.state
  end

  def problem?
    return false if import_job.nil?
    import_job.parse_warnings?
  end

  def failed?
    return false if import_job.nil?
    import_job.failed?
  end

  def imported?
    return false if import_job.nil? || problem? || failed?
    true
  end

  def local_filesystem_path
    # If the file is local, just return the file system path
    csv_file.path
  end

  def file_name
    csv_file_file_name
  end
end
