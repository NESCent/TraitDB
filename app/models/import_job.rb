class ImportJob < ActiveRecord::Base
  belongs_to :csv_dataset
  attr_accessible :status, :csv_dataset
end
