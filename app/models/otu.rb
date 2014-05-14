class Otu < ActiveRecord::Base
  attr_accessible :author, :import_job, :notes, :taxa
  belongs_to :project
  # name and sort_name are based on taxa.
  # For performance reasons, these are cached in the otus table
  has_and_belongs_to_many :taxa, :after_add => :update_names, :after_remove => :update_names
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
  scope :by_project, lambda{|p| where(:project_id => p) unless p.nil?}
  scope :sorted, -> { order('sort_name ASC') }

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

  def categorical_traits
    categorical_trait_categories.map{|x| x.categorical_trait}.uniq
  end

  def continuous_traits
    continuous_trait_values.map{|x| x.continuous_trait}.uniq
  end

  def dataset_name
    csv_dataset.file_name if csv_dataset
  end

  def generate_names
    # Sort name is the entire taxonomy
    names = taxa.sorted_by_iczn.pluck('taxa.name')
    self.sort_name = names.join(' ')
    # Use genus and species if they're available
    genus_species = iczn_groups.by_name(['genus','species']).sorted
    if genus_species.count == 2
        self.name = "#{taxa.in_iczn_group(genus_species.first).first.name} #{taxa.in_iczn_group(genus_species.last).first.name}"
      else
        self.name = names.length >= 2 ? names[-2,2].join(' ') : names.join(' ')
      end
  end

  def update_names(taxon)
    generate_names
  end

  def metadata_hash
    otu_metadata_values.map{|x| {x.otu_metadata_field.name => x.value}}.inject{|memo, x| memo.merge!(x)}
  end

  # Test that this works scoped inside a project
  def self.create_with_taxa(taxa, import_job)
    return nil if taxa.empty?
    return nil if import_job.nil?
    otu = self.create(:taxa => taxa,:import_job => import_job)
    otu.generate_names
    otu.save
    return otu
  end

  # Add metadata to the OTU, including notes, entry email, etc
  # Test that values are saved after adding
  def add_metadata(metadata_hash)
    metadata_hash.each do |name, value|
      next if name.nil? || value.nil?
      model_field = OtuMetadataField.where(:name => name).first_or_create
      model_value = otu_metadata_values.create(:value => value,
                                               :otu_metadata_field => model_field)
    end
  end

end
