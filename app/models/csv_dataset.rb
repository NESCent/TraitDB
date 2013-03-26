class CsvDataset < ActiveRecord::Base
  attr_accessible :csv_file
  has_attached_file :csv_file
  belongs_to :project
  belongs_to :user
  has_one :import_job, :dependent => :destroy

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
