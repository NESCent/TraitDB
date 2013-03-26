class Header < ActiveRecord::Base
  attr_accessible :column_name
  belongs_to :import_job
end
