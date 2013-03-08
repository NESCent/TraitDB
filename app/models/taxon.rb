class Taxon < ActiveRecord::Base
  attr_accessible :name, :uri, :import_job, :parent
  belongs_to :iczn_group
  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  has_many :otus, :dependent => :destroy

  has_many :child_taxa, :class_name => 'TaxonAncestor', :foreign_key => 'parent_id'
  has_many :children, :through => :child_taxa, :dependent => :destroy
  
  has_one :parent_taxon, :class_name => 'TaxonAncestor', :foreign_key => 'child_id'
  has_one :parent, :through => :parent_taxon

  scope :sorted, order('taxa.name ASC')

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end
  
  def iczn_group_name
    iczn_group.name if iczn_group
  end
  
  def parent_name
    parent.name if parent
  end

end
