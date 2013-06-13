class OtuMetadataValue < ActiveRecord::Base
  attr_accessible :value
  belongs_to :otu
  belongs_to :otu_metadata_field
end
