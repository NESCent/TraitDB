# This class is identical to ValidationIssue, see how to combine them
# Tried a module and tried a subclass.  Neither were well-liked

class ImportIssue < ActiveRecord::Base
  attr_accessible :column_location, :column_name, :row_location, :issue_description, :suggested_solution
  belongs_to :import_job
  validates_presence_of :column_location
  validates_presence_of :row_location
  validates_presence_of :issue_description
  validates_presence_of :suggested_solution
end
