class Taxon < ActiveRecord::Base
  attr_accessible :name, :uri
  belongs_to :iczn_group
  belongs_to :import_job
  has_many :otus

  has_many :child_taxa, :class_name => 'TaxonAncestor', :foreign_key => 'parent_id'
  has_many :children, :through => :child_taxa
  
  has_one :parent_taxon, :class_name => 'TaxonAncestor', :foreign_key => 'child_id'
  has_one :parent, :through => :parent_taxon

end
