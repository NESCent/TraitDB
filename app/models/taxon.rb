class Taxon < ActiveRecord::Base
  attr_accessible :name, :uri, :import_job, :parent
  belongs_to :iczn_group

  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  has_many :otus, :dependent => :destroy, :foreign_key => :species_taxon_id

  has_many :child_taxa, :class_name => 'TaxonAncestor', :foreign_key => 'parent_id'
  has_many :children, :through => :child_taxa, :dependent => :destroy
  
  has_one :parent_taxon, :class_name => 'TaxonAncestor', :foreign_key => 'child_id'
  has_one :parent, :through => :parent_taxon

  has_and_belongs_to_many :trait_groups

  scope :sorted, order('name ASC')

  scope :species_taxa, where(:iczn_group_id => IcznGroup.find_by_name("species"))
  scope :family_taxa, where(:iczn_group_id => IcznGroup.find_by_name("family"))
  scope :order_taxa, where(:iczn_group_id => IcznGroup.find_by_name("order"))
  scope :genus_taxa, where(:iczn_group_id => IcznGroup.find_by_name("genus"))
  scope :ungrouped_taxa, where(:iczn_group_id => nil)

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end
  
  def iczn_group_name
    iczn_group.name if iczn_group
  end
  
  def parent_name
    parent.name if parent
  end

  # No longer used anywhere
  def descendant_taxa
    descendants = []
    children.each do |c|
      descendants << c.id
      descendants += c.descendant_taxa
    end
    return descendants
  end

  def descendant_otus
    Otu.where(:species_taxon_id => descendant_taxa)
  end

  def ancestor_with_iczn_group_name(name)
    if iczn_group_name == name
      return self
    elsif parent
      return parent.ancestor_with_iczn_group_name(name)
    else
      return nil
    end
  end

end
