class Otu < ActiveRecord::Base
  attr_accessible :author, :import_job, :notes, :taxa
  has_and_belongs_to_many :taxa
  has_many :iczn_groups, :through => :taxa
  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  has_many :categorical_trait_values, :dependent => :destroy
  has_many :categorical_trait_categories, :through => :categorical_trait_values
  has_many :continuous_trait_values, :dependent => :destroy
  has_many :categorical_trait_notes, :dependent => :destroy
  has_many :continuous_trait_notes, :dependent => :destroy
  has_many :otu_metadata_values, :dependent => :destroy
  has_many :otu_metadata_fields, :through =>  :otu_metadata_values

  scope :by_iczn_group, lambda{|iczn_group| iczn_group.taxa.otus}

  def taxon_name_for_iczn_group(iczn_group)
    taxon = taxa.where(:iczn_group => iczn_group).first
    if taxon
      taxon.name
    else
      nil
    end
  end

  # may be useful, not sure
  def lowest_iczn_group
    iczn_groups.sorted.last
  end

  def lowest_name
    names_by_group.last
  end

  def names_by_group # Returns an array of hashes - ordered in descending hierarchy
    taxa.sorted_by_iczn.map{|taxon| {taxon.iczn_group_name => taxon.name}}
  end

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
    "#{genus_taxon.name} #{species_name}"
  end

  def sort_name
    names_by_group().join(' ')
  end

  def species_name
    names_by_group()['species']
  end

  def genus_name
    names_by_group()['genus']
  end

  def family_name
    names_by_group()['family']
  end

  def order_name
    names_by_group()['order']
  end

  def htg_name
    names_by_group()['htg']
  end

  def continuous_trait_notes_text(continuous_trait_id)
    trait_notes = continuous_trait_notes.where(:continuous_trait_id => continuous_trait_id).first
    if trait_notes
      trait_notes.notes
    else
      nil
    end
  end

  def categorical_trait_notes_text(categorical_trait_id)
    trait_notes = categorical_trait_notes.where(:categorical_trait_id => categorical_trait_id).first
    if trait_notes
      trait_notes.notes
    else
      nil
    end
  end

  def metadata_hash
    otu_metadata_values.map{|x| {x.otu_metadata_field.name => x.value}}.inject{|memo, x| memo.merge!(x)}
  end

end
