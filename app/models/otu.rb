class Otu < ActiveRecord::Base
  attr_accessible :author, :species_taxon, :genus_taxon, :family_taxon, :order_taxon, :htg_taxon, :import_job, :notes
  belongs_to :species_taxon, :class_name => 'Taxon', :foreign_key => 'species_taxon_id'
  belongs_to :genus_taxon, :class_name => 'Taxon', :foreign_key => 'genus_taxon_id'
  belongs_to :family_taxon, :class_name => 'Taxon', :foreign_key => 'family_taxon_id'
  belongs_to :order_taxon, :class_name => 'Taxon', :foreign_key => 'order_taxon_id'
  belongs_to :htg_taxon, :class_name => 'Taxon',  :foreign_key => 'htg_taxon_id'

  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  has_many :categorical_trait_values, :dependent => :destroy
  has_many :categorical_trait_categories, :through => :categorical_trait_values
  has_many :continuous_trait_values, :dependent => :destroy
  has_many :categorical_trait_notes, :dependent => :destroy
  has_many :continuous_trait_notes, :dependent => :destroy

  scope :in_taxon, lambda{|taxon_id, iczn_group_name| where("#{iczn_group_name}_taxon_id = ?", taxon_id)}
  scope :in_species, lambda {|taxon_id| in_taxon(taxon_id, 'species')}
  scope :in_genus, lambda {|taxon_id| in_taxon(taxon_id, 'genus')}
  scope :in_family, lambda {|taxon_id| in_taxon(taxon_id, 'family')}
  scope :in_order, lambda {|taxon_id| in_taxon(taxon_id, 'order')}
  scope :in_htg, lambda {|taxon_id| in_taxon(taxon_id, 'htg')}

  def categorical_traits
    categorical_trait_categories.map{|x| x.categorical_trait}.uniq
  end

  def continuous_traits
    continuous_trait_values.map{|x| x.continuous_trait}.uniq
  end

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end

  def name
    "#{genus_taxon.name} #{species_taxon.name}"
  end

  def sort_name
    "#{htg_taxon.name} #{family_taxon.name} #{order_taxon.name} #{genus_taxon.name} #{species_taxon.name}"
  end

  def species_name
    species_taxon ? species_taxon.name : nil
  end

  def genus_name
    genus_taxon ? genus_taxon.name : nil
  end

  def family_name
    family_taxon ? family_taxon.name : nil
  end

  def order_name
    order_taxon ? order_taxon.name : nil
  end

  def htg_name
    htg_taxon ? htg_taxon.name : nil
  end

end
