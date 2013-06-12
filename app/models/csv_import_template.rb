class CsvImportTemplate < ActiveRecord::Base
  attr_accessible :template_file
  has_attached_file :template_file
  belongs_to :project
  belongs_to :user
  has_many :import_jobs
  validates_attachment_presence :template_file
end
