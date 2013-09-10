require 'traitdb_import/import_template'
class CsvImportTemplate < ActiveRecord::Base
  attr_accessible :template_file
  has_attached_file :template_file
  belongs_to :project
  belongs_to :user
  has_many :import_jobs
  validates_attachment_presence :template_file
  scope :by_project, lambda{|p| where(:project_id => p) unless p.nil?}

  def get_import_template
    TraitDB::ImportTemplate.new(template_file.path)
  end

  def update_name
    self.name = get_import_template.name
  end
end
