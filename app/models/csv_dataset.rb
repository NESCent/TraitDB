class CsvDataset < ActiveRecord::Base
  attr_accessible :csv_file
  has_attached_file :csv_file
  belongs_to :project
  belongs_to :user
  has_one :import_job, :dependent => :destroy
  validates_attachment_presence :csv_file
  validates_attachment_size :csv_file, :greater_than => 0.bytes, :unless => Proc.new { |imports| imports.csv_file_file_name.blank? }
  validates_attachment_content_type :csv_file, :content_type => 'text/csv'

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

end
