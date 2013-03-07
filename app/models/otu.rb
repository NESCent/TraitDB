class Otu < ActiveRecord::Base
  attr_accessible :author, :name
  belongs_to :taxon
  belongs_to :import_job
end
