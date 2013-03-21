# This class is identical to ValidationIssue, see how to combine them
# Tried a module and tried a subclass.  Neither were well-liked

class ParseIssue < ActiveRecord::Base
  attr_accessible :column_location, :column_name, :row_location, :row_name, :issue_description, :suggested_solution
  belongs_to :import_job
  validates_presence_of :column_location
  validates_presence_of :row_location
  validates_presence_of :issue_description
  validates_presence_of :suggested_solution

  def location
    "Row #{row_location}, Column #{column_location} '#{column_name}'"
  end

end
