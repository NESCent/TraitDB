class Otu < ActiveRecord::Base
  attr_accessible :author, :name, :taxon, :import_job
  belongs_to :taxon
  belongs_to :import_job
end
