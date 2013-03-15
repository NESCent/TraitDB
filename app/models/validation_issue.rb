# This class is identical to ImportIssue, see how to combine them

class ValidationIssue < ActiveRecord::Base
  attr_accessible :column_location, :column_name, :row_location, :issue_description, :suggested_solution
  belongs_to :import_job
  validates_presence_of :column_location
  validates_presence_of :row_location
  validates_presence_of :issue_description
  validates_presence_of :suggested_solution
end
