class TaxonAncestor < ActiveRecord::Base
  attr_accessible :parent_id, :child_id
  belongs_to :parent, :class_name => "Taxon"
  belongs_to :child, :class_name => "Taxon"
    
end
