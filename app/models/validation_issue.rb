# This class is identical to ParseIssue, see how to combine them

class ValidationIssue < ActiveRecord::Base
  attr_accessible :column_name, :column_location, :issue_description, :suggested_solution
  belongs_to :import_job
  validates_presence_of :issue_description
  validates_presence_of :suggested_solution

  def location
    if column_location.nil?
      "Headers"
    else
      "Column #{column_location}: #{column_name}"
    end

  end

  def row_name
    {}
  end
end
