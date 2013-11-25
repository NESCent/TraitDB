class OtuMetadataField < ActiveRecord::Base
  attr_accessible :name
  has_many :otu_metadata_values
  has_many :otus, :through => :otu_metadata_values
end
