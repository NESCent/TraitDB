class TaxonAncestor < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :parent, :class_name => "Taxon"
  belongs_to :child, :class_name => "Taxon"
    
end
