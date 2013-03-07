class Taxon < ActiveRecord::Base
  attr_accessible :name, :uri
  belongs_to :iczn_group
  belongs_to :import_job
  has_many :otus
end
