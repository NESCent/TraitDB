require 'treeofsex_import/validator'

class ImportJob < ActiveRecord::Base
  belongs_to :csv_dataset
  has_many :taxa
  has_many :otus
  has_many :parse_issues, :dependent => :destroy
  has_many :validation_issues, :dependent => :destroy
  has_many :headers, :dependent => :destroy

  attr_accessible :state, :csv_dataset
  attr_accessible :quantitative_header_start_id, :quantitative_header_end_id, :qualitative_header_start_id, :qualitative_header_end_id
  
  IMPORT_STATES = %w(new reading_headers read_headers headers_failed count_failed counted_rows validating validated validation_failed parsing parsed parse_warnings importing imported import_failed)
  validates_inclusion_of :state, :in => IMPORT_STATES
  def file_name
    csv_dataset.csv_file_file_name
  end

  def validation_failed?
    state == 'validation_failed'
  end

  def failed?
    state.include?('failed')
  end

  def imported?
    state == 'imported'
  end

  def parse_warnings?
    state.include?('warnings')
  end

  def parsed_rows?
    %w(parsed parse_warnings).include?('state')
  end

  def running?
    %w(validating parsing importing).include?(state)
  end

  def validated_headers?
    state == 'validated'
  end

  def new?
    state == 'new'
  end

  # Used to create a new CSV file with just the bad data
  def problem_rows
    parse_issues.map { |i| i.row_location}.uniq
  end

  def problem_rows_cols
    parse_issues.map{ |i| {:row => i.row_location, :column => i.column_location }}
  end

  def reset
    self.state = 'new'
    save
  end

  def read_headers
    return false unless state == 'new'
    begin
      headers.clear
      CSV.read(csv_dataset.csv_file.path, :headers => true).headers.each do |h|
        headers << Header.new(:column_name => h)
      end
      self.state = 'read_headers'
      save
    rescue # file is not a CSV
      self.state = 'headers_failed'
      save
    end
  end

  def count_rows
    return false unless state == 'read_headers'
    begin
      self.csv_row_count = CSV.read(csv_dataset.csv_file.path, :headers => true).length
      self.state = 'counted_rows'
    rescue # file is not a CSV
      self.state = 'count_failed'
    end
    save
  end


  # designed to run async via delayed job
  def do_validation
    return false unless state == 'counted_rows'
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

  # These methods are a workaround for has_one and has_many in the same model
  def quantitative_header_start
    headers.find(quantitative_header_start_id)
  end

  def quantitative_header_end
    headers.find(quantitative_header_end_id)
  end

  def qualitative_header_start
    headers.find(qualitative_header_start_id)
  end

  def qualitative_header_end
    headers.find(qualitative_header_end_id)
  end

  private

  # The validator is a non-rails ruby class.  It is not persisted and its state isn't
  # serializable.  Since the validate/parse/import is several steps, we need to be able to
  # reconstructa validator each time.  Would be nice to refactor this.

  def get_validator
    validator = TreeOfSexImport::Validator.new(csv_dataset.csv_file.path)

    validator.quantitative_header_start = self.quantitative_header_start.column_name
    validator.quantitative_header_end = self.quantitative_header_end.column_name
    validator.qualitative_header_start = self.qualitative_header_start.column_name
    validator.qualitative_header_end = self.qualitative_header_end.column_name
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
        self.parse_issues << ParseIssue.create(issue)
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
          otu = Otu.create(:name => otu_name, :taxon => last_parent, :import_job => self, :notes => otu_notes)
          # refs
          # Categorical Traits
          d[:qualitative_data].each do |import_trait|
            # skip if source is not provided
            next if import_trait[:source].nil?
            # an array of hashes.  Hashes contain :name, :values, and :source
            # find the trait to attach it to
            trait = CategoricalTrait.where(:name => import_trait[:name]).first
            # This will result in erroneous references if source is nil, because where(nil) returns everything!
            source_reference = SourceReference.where(import_trait[:source]).first_or_create do |ref|
              import_datasets_messages << "Adding Source Reference #{ref[:title]}"
            end

            import_trait[:values].each_with_index do |import_value, i|
              # Now the values
              category = CategoricalTraitCategory.where(:categorical_trait_id => trait.id, :name => import_value).first
              value = CategoricalTraitValue.create(:position => i,
                                                   :categorical_trait_id => trait.id,
                                                   :categorical_trait_category_id => category.id,
                                                   :source_reference_id => source_reference.id)
              source_reference.categorical_trait_values << value
              otu.categorical_trait_values << value
              otu.save
            end
            source_reference.save
          end
          d[:quantitative_data].each do |import_trait|
            # skip if source is not provided
            next if import_trait[:source].nil?
            # Array of hashes.  Hashes contain :name, :value, and :source
            trait = ContinuousTrait.where(:name => import_trait[:name]).first
            # This will result in erroneous references if source is nil, because where(nil) returns everything!
            source_reference = SourceReference.where(import_trait[:source]).first_or_create do |ref|
              import_datasets_messages << "Adding Source Reference #{ref[:title]}"
            end

            value = ContinuousTraitValue.create(:continuous_trait_id => trait.id,
                                                :value => import_trait[:value],
                                                :source_reference_id => source_reference.id)
            source_reference.continuous_trait_values << value
            source_reference.save
            otu.continuous_trait_values << value
            otu.save
          end
        end
      end #end of datasets.each
  end

  
end
