require 'traitdb_import/validator'
require 'traitdb_import/import_template'

class ImportJob < ActiveRecord::Base
  belongs_to :csv_dataset
  has_many :taxa
  has_many :otus
  has_many :parse_issues, :dependent => :destroy
  has_many :validation_issues, :dependent => :destroy
  has_many :headers, :dependent => :destroy
  belongs_to :csv_import_config
  has_one :project, :through => :csv_dataset

  before_save :update_config_state

  attr_accessible :state, :csv_dataset
  attr_accessible :csv_import_config_id
  
  IMPORT_STATES = %w(new reading_headers read_headers headers_failed count_failed counted_rows selecting_config selected_config validating validated validation_failed parsing parsed parse_warnings importing imported import_failed)
  validates_inclusion_of :state, :in => IMPORT_STATES
  def file_name
    csv_dataset.file_name
  end

  def validation_failed?
    state == 'validation_failed'
  end

  def failed?
    state.include?('failed')
  end

  def importing?
    state == 'importing'
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

  def selected_config?
    IMPORT_STATES.index(state) >= IMPORT_STATES.index('selected_config')
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
      CSV.foreach(csv_dataset.get_local_file, :encoding => csv_dataset.encoding) do |row|
        # rows are not escaped properly
        if i == 0 || row_indices.include?(i + 1)
          csv << row
        end
        i += 1
      end
    end
    output_csv_string
  end

  def download_issues_csv_string
    CSV.generate do |csv|
      csv << ['Genus', 'Species', 'CSV Row Number', 'CSV Column Number', 'CSV Column Name', 'Problem', 'Possible Solution']
      # loop over the issues
      # print them to the report
      parse_issues.each do |issue|
        csv << [issue.row_name['genus'], issue.row_name['species'], issue.row_location, issue.column_location, issue.column_name, issue.issue_description, issue.suggested_solution]
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
      CSV.read(csv_dataset.get_local_file, :headers => true, :encoding => csv_dataset.encoding).headers.each do |h|
        headers << Header.new(:column_name => h)
      end
      self.state = 'read_headers'
      save
    rescue Exception => e
      if e.message == 'invalid byte sequence in UTF-8' && csv_dataset.encoding.nil?
        # Probably an Excel-encoded ISO-8859-1 file, try again with that encoding
        csv_dataset.encoding = 'ISO-8859-1'
        csv_dataset.save
        # Try again
        read_headers
      else
        # file is not a CSV
        self.state = 'headers_failed'
        self.validation_issues.create({:issue_description => e.message, :suggested_solution => 'Please upload a valid CSV file'})
        save
      end
    end
  end

  def count_rows
    return false unless state == 'read_headers'
    begin
      self.csv_row_count = CSV.read(csv_dataset.get_local_file, :headers => true, :encoding => csv_dataset.encoding).length
      self.state = 'counted_rows'
    rescue Exception => e
     # file is not a CSV
      self.state = 'count_failed'
      self.validation_issues.create({:issue_description => e.message, :suggested_solution => 'Please upload a valid CSV file'})

    end
    save
  end

  def update_config_state
    if state =='counted_rows'
      if csv_import_config
        self.state = 'selected_config'
      end
    end
  end


  # designed to run async via delayed job
  def do_validation
    return false unless state == 'selected_config'
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
    save
    if import_dataset
      self.state = 'imported'
    else
      self.state = 'import_failed'
    end
    save
  end


  def extra_headers
    possible_headers = csv_import_config.get_import_template.all_column_headers
    actual_headers = headers.pluck(:column_name)
    extra_headers = actual_headers - possible_headers
    return extra_headers.uniq.reject &:blank?
  end

  def has_extra_headers?
    !extra_headers.empty?
  end
  private

  # The validator is a non-rails ruby class.  It is not persisted and its state isn't
  # serializable.  Since the validate/parse/import is several steps, we need to be able to
  # reconstructa validator each time.  Would be nice to refactor this.

  def get_validator
    # validator needs a template
    template = csv_import_config.get_import_template
    validator = TraitDB::Validator.new(template, csv_dataset.get_local_file, csv_dataset.encoding)
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
    import_traits(validator.trait_headers)
    import_datasets(validator.datasets)
    link_trait_groups # done after import
    true
  end

  def import_traits(traits)
    messages = []
    template = csv_import_config.get_import_template
    # trait definitions to be imported into database.
    traits[:continuous].each do |import_trait|
      setup_trait = lambda do |trait|
        messages << "Adding continuous trait #{import_trait[:name]}"
        trait.import_job = self
        trait.project = project
        if import_trait[:format]
          trait.display_format = DisplayFormat.where(:name => import_trait[:format]).first
        end
        if import_trait[:summarization_method]
          trait.summarization_method = import_trait[:summarization_method]
        end
      end

      # Find or create a trait set for each level and the last delimiter becomes the name of the trait
      if template.trait_sets?
        path = template.trait_path_from_column(import_trait[:name])
        set = TraitSet.find_or_create_with_path(project, path[0..-2])
        continuous_trait = set.continuous_traits.where(:name => path[-1]).first_or_create &setup_trait
        set.save
        continuous_trait.save
      else
        continuous_trait = ContinuousTrait.by_project(project).where(:name => import_trait[:name]).first_or_create &setup_trait
      end
      if import_trait[:groups]
        import_trait[:groups].each do |import_group_name|
          group = TraitGroup.by_project(project).where(:name => import_group_name).first_or_create
          group.continuous_traits << continuous_trait unless continuous_trait.in? group.continuous_traits
          group.save
        end
      end
      continuous_trait.save
    end

    traits[:categorical].each do |import_trait|
      setup_trait = lambda do |trait|
        messages << "Adding categorical trait #{import_trait[:name]}"
        trait.import_job = self
        trait.project = project
        if import_trait[:format]
          trait.display_format = DisplayFormat.where(:name => import_trait[:format]).first
        end
        if import_trait[:summarization_method]
          trait.summarization_method = import_trait[:summarization_method]
        end
      end

      # Find or create a trait set for each level and the last delimiter becomes the name of the trait
      if template.trait_sets?
        path = template.trait_path_from_column(import_trait[:name])
        set = TraitSet.find_or_create_with_path(project, path[0..-2])
        categorical_trait = last_set.categorical_traits.where(:name => path[-1]).first_or_create &setup_trait
        set.save
        categorical_trait.save
      else
        categorical_trait = CategoricalTrait.by_project(project).where(:name => import_trait[:name]).first_or_create &setup_trait
      end

      if import_trait[:groups]
        import_trait[:groups].each do |import_group_name|
          group = TraitGroup.by_project(project).where(:name => import_group_name).first_or_create
          group.categorical_traits << categorical_trait unless categorical_trait.in? group.categorical_traits
          group.save
        end
      end

      import_trait[:values].each do |value|
        categorical_trait.categorical_trait_categories.where(:name => value).first_or_create do |category|
          messages << "Adding category #{value} to #{import_trait[:name]}"
        end
      end
      categorical_trait.save
    end
    messages
  end

  def import_datasets(datasets)
    # datasets is an Array of Hashes from the validator
    template = csv_import_config.get_import_template
      datasets.each do |d|
        # Create taxa
        taxonomy_hash = d[:taxon]
        ordered_taxonomy = get_ordered_taxa_iczngroups(taxonomy_hash)
        row_taxa = Taxon.find_or_create_with_ordered_taxonomy(ordered_taxonomy, self)

        # Add Iczn Groups to project
        iczn_groups = ordered_taxonomy.map{|taxon| taxon[:iczn_group]}
        project.add_iczn_groups(iczn_groups)

        # Create an OTU
        otu = Otu.by_project(project).create_with_taxa(row_taxa, self)
        metadata_hash = d[:metadata]
        otu.add_metadata(metadata_hash)

        # Categorical Traits
        categorical_trait_hashes = d[:categorical_trait_data]
        add_categorical_traits(otu, template, categorical_trait_hashes)

        # Continuous Traits
        continuous_trait_hashes = d[:continuous_trait_data]
        add_continuous_traits(otu, template, continuous_trait_hashes)
      end
    project.save
  end

  # This new stuff should be private
  # also needs to be refactored to make instance variables

  # given a hash of iczn group names to taxa (e.g.{'Kingdom' => 'Plantae', 'htg' => 'Angiosperms'},
  # returns an array, ordered by descending IcznGroup level, with elements that indicate a
  # taxon name and an iczn group
  def get_ordered_taxa_iczngroups(taxon_hash)
    ordered_taxa_iczngroups = []
    IcznGroup.sorted.each do |iczn_group|
      if iczn_group.name.in? taxon_hash.keys
        ordered_taxa_iczngroups << {:taxon_name => taxon_hash[iczn_group.name],
                                    :iczn_group => iczn_group}
      end
    end
    return ordered_taxa_iczngroups
  end


  # Can go in source_reference.rb
  # Given a source name (e.g. 'Book of things 2009')
  # creates a SourceReference object in the current project with it.
  def add_trait_source(trait_source)
    return nil unless trait_source
    return SourceReference.by_project(project).where(:source => trait_source).first_or_create
  end

  # categorical_trait_hashes is an array of hashes.  Hashes contain :name, :values, and :source
  # Source may be nil if the template allowed it.  This would have been checked by the validator already
  # find the trait to attach it to
  def add_categorical_traits(otu, template, categorical_trait_hashes)
    categorical_trait_hashes.each do |categorical_trait_hash|
      model_trait = get_categorical_trait(template, categorical_trait_hash)
      model_source_reference = add_trait_source(categorical_trait_hash[:source])
      add_categorical_trait_values(otu, model_trait, categorical_trait_hash[:values], model_source_reference)
      add_categorical_trait_note(otu, model_trait, categorical_trait_hash[:notes])
    end
    otu.save
  end

  # should go in categorical_trait.rb
  # Fetches the trait from the database.  Trait must exist
  # behaves differently if template uses trait sets or not

  def get_categorical_trait(template, categorical_trait_hash)
    if template.trait_sets?
      # This is messy because I can't remember why the path 0..-2 is significant or how the paths are constructed
      path = template.trait_path_from_column(categorical_trait_hash[:name])
      model_trait = TraitSet.find_or_create_with_path(project, path[0..-2]).categorical_traits.where(:name => path[-1]).first
    else
      model_trait = CategoricalTrait.by_project(project).where(:name => categorical_trait_hash[:name]).first
    end
    model_trait
  end

# Given an otu, a trait, an array of values, and an optionally nil source reference
# creates an indexed categorical trait value for each value.  Links the trait value to the source if the source is not nil
  def add_categorical_trait_values(otu, model_trait, categorical_trait_values, model_source_reference)
    categorical_trait_values.each_with_index do |trait_value, index|
      model_value = add_categorical_trait_value(otu, model_trait, trait_value, index)
      link_categorical_value_to_source_reference(model_value, model_source_reference) if model_source_reference
      model_value.save
    end
  end

  # Creates a CategoricalTraitValue object
  # with the specified category
  # assumes the categoricalTraitCategory exists
  # creates the model value.  values are just references to categories, traits, and a position
  # should this go in CategoricalTrait.rb or CategoricalTraitValue.rb?
  def add_categorical_trait_value(otu, model_trait, trait_value, index)
    model_category = CategoricalTraitCategory.where(:categorical_trait_id => model_trait.id, :name => trait_value).first
    model_value = CategoricalTraitValue.create(:otu_id => otu.id,
                                               :position => index,
                                               :categorical_trait_id => model_trait.id,
                                               :categorical_trait_category_id => model_category.id
    )
    return model_value

  end

  def link_categorical_value_to_source_reference(model_value, model_source_reference)
    return if model_source_reference.nil?
    model_value.source_reference = model_source_reference
    model_source_reference.categorical_trait_values << model_value
    model_value.save
    model_source_reference.save
  end

  # Given a string containing a trait note, create a CategoricalTraitNote object and link it to the model_trait
  # move to CategoricalTraitNote.rb or Otu.rb?
  # Test that on adding a categorical trait note, the note appears in the otus relationship
  def add_categorical_trait_note(otu, model_trait, trait_note)
    return CategoricalTraitNote.create(:otu_id => otu.id,
                                       :categorical_trait_id => model_trait.id,
                                       :notes => trait_note)
  end

  # continuous_trait_hashes is an array of hashes.  Hashes contain :name, :values, and :source
  # source may be nil if the template allowed it.  This should have been checked by the validator already
  # traits themselves are pre-existing in the database
  def add_continuous_traits(otu, template, continuous_trait_hashes)
    continuous_trait_hashes.each do |continuous_trait_hash|
      model_trait = get_continuous_trait(template, continuous_trait_hash)
      model_source_reference = add_trait_source(continuous_trait_hash[:source])
      add_continuous_trait_values(otu, model_trait, continuous_trait_hash[:values], model_source_reference)
      add_continuous_trait_note(otu, model_trait, continuous_trait_hash[:notes])
    end
    otu.save
  end

  # should go in continuous_trait.rb
  # Fetches the trait from the database.  Trait must exist
  # behaves differently if template uses trait sets or not
  def get_continuous_trait(template, continuous_trait_hash)
    if template.trait_sets?
      # This is messy because I can't remember why the path 0..-2 is significant or how the paths are constructed
      path = template.trait_path_from_column(continuous_trait_hash[:name])
      model_trait = TraitSet.find_or_create_with_path(project, path[0..-2]).continuous_traits.where(:name => path[-1]).first
    else
      model_trait = ContinuousTrait.by_project(project).where(:name => continuous_trait_hash[:name]).first
    end
    model_trait

  end

  # where should this go?
  def add_continuous_trait_values(otu, model_trait, continuous_trait_values, model_source_reference)
    continuous_trait_values.each_with_index do |trait_value, index|
      model_value = add_continuous_trait_value(otu, index, model_trait, trait_value)
      link_continuous_value_to_source_reference(model_value, model_source_reference) if model_source_reference
    end
  end

  # where should this go?
  def add_continuous_trait_value(otu, index, model_trait, trait_value)
    model_value = ContinuousTraitValue.create(:otu_id => otu.id,
                                              :position => index,
                                              :continuous_trait_id => model_trait.id,
                                              :value => trait_value)
    return model_value
  end

  # This should go in ContinuousTraitValue.rb
  # Test if it's even necessary to add the model_value to the array of continuous / categorical values
  def link_continuous_value_to_source_reference(model_value, model_source_reference)
    return if model_source_reference.nil?
    model_value.source_reference = model_source_reference
    # Is this even necessary
    model_source_reference.continuous_trait_values << model_value
    model_value.save
    model_source_reference.save
  end

  # should go in ContinuousTraitNote.rb
  def add_continuous_trait_note(otu, model_trait, trait_note)
    return ContinuousTraitNote.create(:otu_id => otu.id,
                                      :continuous_trait_id => model_trait.id,
                                      :notes => trait_note)
  end

  def link_trait_groups
    template = csv_import_config.get_import_template
    template.trait_group_names.each do |trait_group_name|
      trait_group = TraitGroup.by_project(project).find_by_name(trait_group_name)
      next if trait_group.nil?

      # Only set groups for taxa in this project
      iczn_group = project.iczn_groups.where(:name => template.trait_group_rank(trait_group_name)).first
      next if iczn_group.nil?

      iczn_group.taxa.by_project(project).where(:name => template.trait_group_taxon_name(trait_group_name)).each do |taxon|
        taxon.trait_groups << trait_group unless trait_group.in? taxon.trait_groups
        taxon.save
      end
    end
  end
  
end
