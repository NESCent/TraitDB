require 'treeofsex_import/validator'

class ImportJob < ActiveRecord::Base
  belongs_to :csv_dataset
  has_many :taxa
  has_many :otus
  has_many :import_issues, :dependent => :destroy
  has_many :validation_issues, :dependent => :destroy

  attr_accessible :state, :csv_dataset
  attr_accessible :quantitative_header_start, :quantitative_header_end, :qualitative_header_start, :qualitative_header_end
  IMPORT_STATES = %w(new validating validated validation_failed parsing parsed parse_warnings importing imported import_failed)
  validates_inclusion_of :state, :in => IMPORT_STATES

  def reset
    self.state = 'new'
    save
  end

  # designed to run async via delayed job
  def do_validation
    return false unless state == 'new'
    self.state = 'validating'
    if validate_dataset
      self.state = 'validated'
    else
      self.state = 'validation_failed'
    end
    save
  end

  # designed to run async via delayed job
  def do_parse
    # fail if state is not validated
    return false unless state == 'validated'
    self.state = 'parsing'
    save
    if parse_dataset
      self.state = 'parsed'
    else
      self.state = 'parse_warnings'
    end
    save
  end

  # designed to run async via delayed job
  def do_import
    # fail if state is not parsed
    return false unless state.in? ['parsed', 'parse_warnings']
    self.state = 'importing'
    if import_dataset
      self.state = 'imported'
    else
      self.state = 'import_failed'
    end
    save
  end

  private

  # validator is not persisted and state isn't currently saved
  # since the validate/parse/import is 3 separate steps, this needs to
  # rebuild the validator each time
  # This needs refactoring

  def get_validator
    validator = TreeOfSexImport::Validator.new(csv_dataset.csv_file.path)

    validator.quantitative_header_start = self.quantitative_header_start
    validator.quantitative_header_end = self.quantitative_header_end
    validator.qualitative_header_start = self.qualitative_header_start
    validator.qualitative_header_end = self.qualitative_header_end
    validator

  end

  def validate_dataset
    validator = get_validator
    results = validator.validate
    if results[:issues].empty?
      # no issues
      return true
    else
      results[:issues].each do |issue|
        self.validation_issues << ValidationIssue.create(issue)
      end
      self.save
      return false
    end
  end

  def parse_dataset
    validator = get_validator
    validator.validate
    results = validator.parse
    if results[:issues].empty?
      # no issues,
      return true
    else
      results[:issues].each do |issue|
        self.import_issues << ImportIssue.create(issue)
      end
      self.save
      return false
    end
  end

  def import_dataset
    validator = get_validator
    validator.validate
    validator.parse
    import_chrs(validator.chr_headers)
    import_datasets(validator.datasets)
    true
  end

  def import_chrs(chrs)
    messages = []
    # chrs need to be imported into database.
    quant = chrs[:quantitative]
    quant.each do |chr_name|
      ContinuousTrait.where(:name => chr_name).first_or_create do |trait|
        messages << "Adding continuous character #{chr_name}"
        trait.import_job = self
      end
    end

    qual = chrs[:qualitative]
    qual.each do |chr_hash|
      # each chr is a hash with :raw_header_name, :chr_name, :chr_states
      # see if this project has a character with this name
      # need a chr model!
      categorical_trait = CategoricalTrait.where(:name => chr_hash[:chr_name]).first_or_create do |trait|
        messages << "Adding categorical character #{chr_hash[:chr_name]}"
        trait.import_job = self
      end
      chr_hash[:chr_states].each do |state_name|
        categorical_trait.categorical_trait_categories.where(:name => state_name).first_or_create do |category|
          messages << "Adding state #{state_name} to #{chr_hash[:chr_name]}"
        end
      end
    end
    messages
  end

  def import_datasets(datasets)
    # datasets is an Array of Hashes
    import_datasets_messages = []
    import_datasets_messages << "Received #{datasets.size} datasets"
    @duplicates = []
    # taxa
    
    # need to make an otu out of each or detect if it exists
      datasets.each do |d|
        taxon = d[:taxon]
        otu_name = "#{taxon[:genus].capitalize.strip} #{taxon[:species].capitalize.strip}"
        # Find or create an OTU for this row
        
        # find from parent
        # consider iczn_group names
        # Do we need a root taxon for the project or should there be htg in each
        # project
        
        last_parent = nil
        
        if taxon[:higher_taxonomic_group]
          # Search for Taxon with this name and no parent
          last_parent = Taxon.where(:name => taxon[:higher_taxonomic_group]).first_or_create(:import_job => self)
        end
        
        # order
        if taxon[:order]
          last_parent = last_parent.children.where(:name => taxon[:order]).first_or_create do |t|
            t.parent = last_parent
            t.import_job = self
            t.iczn_group = IcznGroup.find_by_name("order")
          end
        end
        
        # family
        if taxon[:family]
          last_parent = last_parent.children.where(:name => taxon[:family]).first_or_create do |t|
            t.parent = last_parent
            t.import_job = self
            t.iczn_group = IcznGroup.find_by_name("family")
          end
        end
        
        # genus
        if taxon[:genus]
          last_parent = last_parent.children.where(:name => taxon[:genus]).first_or_create do |t|
            t.parent = last_parent
            t.import_job = self
            t.iczn_group = IcznGroup.find_by_name("genus")
          end
        end
        
        # species
        # Validator is not populating author and date into model
        # what about subspecies?
        # can taxonifi help with this?
        if taxon[:species]
          last_parent = last_parent.children.where(:name => taxon[:species]).first_or_create do |t|
            t.parent = last_parent
            t.import_job = self
            t.iczn_group = IcznGroup.find_by_name("species")
          end
          otu_notes = d[:notes_comments]
          # make an otu
          otu = Otu.create(:name => otu_name, :taxon => last_parent, :import_job => self)
          # refs
          # Categorical Traits
          d[:qualitative_data].each do |import_trait|
            # an array of hashes.  Hashes contain :name, :values, and :source
            # find the trait to attach it to
            trait = CategoricalTrait.where(:name => import_trait[:name]).first
            import_trait[:values].each_with_index do |import_value, i|
              # Now the values
              category = CategoricalTraitCategory.where(:categorical_trait_id => trait.id, :name => import_value).first
              value = CategoricalTraitValue.create(:position => i,
                                                   :categorical_trait_id => trait.id,
                                                   :categorical_trait_category_id => category.id)
              otu.categorical_trait_values << value
              otu.save
            end
          end
          d[:quantitative_data].each do |import_trait|
            # Array of hashes.  Hashes contain :name and :value
            trait = ContinuousTrait.where(:name => import_trait[:name]).first
            value = ContinuousTraitValue.create(:continuous_trait_id => trait.id, :value => import_trait[:value])
            otu.continuous_trait_values << value
            otu.save
          end
        end
      end #end of datasets.each
  end

  
end
