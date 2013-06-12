require 'traitdb_import/validator'
require 'traitdb_import/import_template'

class ImportJob < ActiveRecord::Base
  belongs_to :csv_dataset
  has_many :taxa
  has_many :otus
  has_many :parse_issues, :dependent => :destroy
  has_many :validation_issues, :dependent => :destroy
  has_many :headers, :dependent => :destroy
  belongs_to :csv_import_template

  before_save :update_template_state

  attr_accessible :state, :csv_dataset
  attr_accessible :csv_import_template_id
  
  IMPORT_STATES = %w(new reading_headers read_headers headers_failed count_failed counted_rows selecting_template selected_template validating validated validation_failed parsing parsed parse_warnings importing imported import_failed)
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
    state == 'parse_warnings'
  end

  def parsed_rows?
    IMPORT_STATES.index(state) >= IMPORT_STATES.index('parsed')
  end

  def running?
    %w(validating parsing importing).include?(state)
  end

  def read_headers?
    IMPORT_STATES.index(state) >= IMPORT_STATES.index('read_headers')
  end

  def counted_rows?
    IMPORT_STATES.index(state) >= IMPORT_STATES.index('counted_rows')
  end

  def selected_template?
    IMPORT_STATES.index(state) >= IMPORT_STATES.index('selected_template')
  end

  def validated_headers?
    IMPORT_STATES.index(state) >= IMPORT_STATES.index('validated')
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

  def problem_rows_csv_string
    row_indices = problem_rows
    output_csv_string = CSV.generate do |csv|
      i = 0
      CSV.foreach(csv_dataset.csv_file.path) do |row|
        # rows are not escaped properly
        if i == 0 || row_indices.include?(i)
          csv << row
        end
        i += 1
      end
    end
    output_csv_string
  end

  def download_issues_csv_string
    CSV.generate do |csv|
      csv << ['Species Name', 'CSV Row Number', 'CSV Column Number', 'CSV Column Name', 'Problem', 'Possible Solution']
      # loop over the issues
      # print them to the report
      parse_issues.each do |issue|
        csv << ["#{issue.row_name[:genus]} #{issue.row_name[:species]}", issue.row_location, issue.column_location, issue.column_name, issue.issue_description, issue.suggested_solution]
      end
    end
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
    rescue Exception => e
      # file is not a CSV
      self.state = 'headers_failed'
      self.validation_issues.create({:issue_description => e.message, :suggested_solution => 'Please upload a valid CSV file with UTF encoding'})
      save
    end
  end

  def count_rows
    return false unless state == 'read_headers'
    begin
      self.csv_row_count = CSV.read(csv_dataset.csv_file.path, :headers => true).length
      self.state = 'counted_rows'
    rescue Exception => e
     # file is not a CSV
      self.state = 'count_failed'
      self.validation_issues.create({:issue_description => e.message, :suggested_solution => 'Please upload a valid CSV file with UTF encoding'})

    end
    save
  end

  def update_template_state
    if state =='counted_rows'
      if csv_import_template
        self.state = 'selected_template'
      end
    end
  end


  # designed to run async via delayed job
  def do_validation
    return false unless state == 'selected_template'
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

  # The validator is a non-rails ruby class.  It is not persisted and its state isn't
  # serializable.  Since the validate/parse/import is several steps, we need to be able to
  # reconstructa validator each time.  Would be nice to refactor this.

  def get_validator
    # validator needs a template
    template = TraitDB::ImportTemplate.new(csv_import_template.template_file.path)
    validator = TraitDB::Validator.new(template, csv_dataset.csv_file.path)
    validator # returns the validator
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
    import_traits(validator.trait_headers) # Need to handle trait groups
    import_datasets(validator.datasets) # same here, as well as metadata fields
    true
  end

  def import_traits(traits)
    messages = []
    # trait definitions to be imported into database.
    traits[:continuous].each do |import_trait|
      ContinuousTrait.where(:name => import_trait[:name]).first_or_create do |trait|
        messages << "Adding continuous trait #{import_trait[:name]}"
        trait.import_job = self
        if import_trait[:format]
          trait.display_format = DisplayFormat.where(:name => import_trait[:format]).first
          # TODO: add trait group
        end
      end
    end

    traits[:categorical].each do |import_trait|
      categorical_trait = CategoricalTrait.where(:name => import_trait[:name]).first_or_create do |trait|
        messages << "Adding categorical trait #{import_trait[:name]}"
        trait.import_job = self
        if import_trait[:format]
          trait.display_format = DisplayFormat.where(:name => import_trait[:format]).first
          # TODO: add trait group
        end
      end

      import_trait[:values].each do |value|
        categorical_trait.categorical_trait_categories.where(:name => value).first_or_create do |category|
          messages << "Adding category #{value} to #{import_trait[:name]}"
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
        # Find or create an OTU for this row

        # htg, order, family, genus, species, species_author, infraspecific
        last_parent = nil
        # These need to come from the validator and from the IcznGroups
        taxa_map = {'htg'=> nil, 'order' => nil, 'family' => nil, 'genus' => nil, 'species' => nil, 'species_author' => nil, 'infraspecific' => nil}
        # Start with the HTG
        taxa_map.keys.each do |level|
          # level will be 'htg' or 'family', etc.
          next if taxon[level].nil?
          model_taxon = Taxon.where(:name => taxon[level].strip).first_or_create do |t|
            t.parent = last_parent
            t.import_job = self
            t.iczn_group = IcznGroup.find_by_name(level)
          end
          last_parent = taxa_map[level] = model_taxon
        end

        # Create the OTU at the lowest level, may be species
        # TODO: get the metadata (formerly notes, etc)
        otu_metadata = d[:metadata]
        # Metadata will just be stored as a hash, not in columns

        # make an otu
        otu = Otu.create(:species_taxon => taxa_map['species'],
                         :genus_taxon => taxa_map['genus'],
                         :family_taxon => taxa_map['family'],
                         :order_taxon => taxa_map['order'],
                         :htg_taxon => taxa_map['htg'],
                         :import_job => self) # Notes were here

        # refs
        # Categorical Traits
        d[:categorical_trait_data].each do |import_trait|
          # an array of hashes.  Hashes contain :name, :values, and :source
          # Source may be nil if the template allowed it.  This would have been checked by the validator already
          # find the trait to attach it to
          trait = CategoricalTrait.where(:name => import_trait[:name]).first
          # This will result in erroneous references if source is nil, because where(nil) returns everything!
          if import_trait[:source]
            source_reference = SourceReference.where(import_trait[:source]).first_or_create do |ref|
              import_datasets_messages << "Adding Source Reference #{ref[:title]}"
            end
          end

          import_trait[:values].each_with_index do |import_value, i|
            # Now the values
            category = CategoricalTraitCategory.where(:categorical_trait_id => trait.id, :name => import_value).first
            value = CategoricalTraitValue.create(:position => i,
                                                 :categorical_trait_id => trait.id,
                                                 :categorical_trait_category_id => category.id)
            if import_trait[:source]
              value.source_reference = source_reference
              source_reference.categorical_trait_values << value
            end

            otu.categorical_trait_values << value
            value.save
            otu.save
          end
          source_reference.save

          # Record trait notes if present - only one field of notes
          if import_trait[:notes]
            trait_note = CategoricalTraitNote.create(:categorical_trait_id => trait.id,
                                                     :notes => import_trait[:notes])
            otu.categorical_trait_notes << trait_note
            trait_note.save
            otu.save
          end
        end

        d[:continuous_trait_data].each do |import_trait|
          # Array of hashes.  Hashes contain :name, :value, and :source
          trait = ContinuousTrait.where(:name => import_trait[:name]).first
          # This will result in erroneous references if source is nil, because where(nil) returns everything!
          if import_trait[:source]
            source_reference = SourceReference.where(import_trait[:source]).first_or_create do |ref|
              import_datasets_messages << "Adding Source Reference #{ref[:title]}"
            end
          end

          value = ContinuousTraitValue.create(:continuous_trait_id => trait.id,
                                              :value => import_trait[:value])
          if import_trait[:source]
            value.source_reference = source_reference
            source_reference.continuous_trait_values << value
          end
          otu.continuous_trait_values << value
          # Record notes if present - only one field of notes
          if import_trait[:notes]
            trait_note = ContinuousTraitNote.create(:continuous_trait_id => trait.id,
                                                    :notes => import_trait[:notes])
            otu.continuous_trait_notes << trait_note
            trait_note.save
          end
          otu.save
        end
      end #end of datasets.each
  end

  
end
