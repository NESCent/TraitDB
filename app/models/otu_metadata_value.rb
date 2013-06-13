class OtuMetadataValue < ActiveRecord::Base
  attr_accessible :value, :otu, :otu_metadata_field
  belongs_to :otu
  belongs_to :otu_metadata_field
end
