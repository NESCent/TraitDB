require 'treeofsex_import/validator'

class ImportJob < ActiveRecord::Base
  belongs_to :csv_dataset
  has_many :taxa
  has_many :otus
  attr_accessible :status, :csv_dataset
  attr_accessible :quantitative_header_start, :quantitative_header_end, :qualitative_header_start, :qualitative_header_end

  def reset
    self.status = "new"
    save
  end
 
  def do_import
    # fail if status is not new
    unless status == "new"
      return false
    end

    self.status = "importing"
    save
    parsed_datasets, parsed_chrs = validate_dataset
    puts @validator_messages.join("\n")
    unless parsed_chrs && parsed_datasets
      self.status = "failed"
      save
      return false
    end

    import_chrs_messages = import_chrs(parsed_chrs)
    puts import_chrs_messages.join("\n")
    import_datasets_messages = import_datasets(parsed_datasets)
    puts import_datasets_messages.join("\n")
    self.status = "imported"
    save
    true
  end

  private
  
  def validate_dataset
    validator = TreeOfSexImport::Validator.new(csv_dataset.csv_file.path)

    validator.quantitative_header_start = self.quantitative_header_start
    validator.quantitative_header_end = self.quantitative_header_end
    validator.qualitative_header_start = self.qualitative_header_start
    validator.qualitative_header_end = self.qualitative_header_end
    
    success = validator.validate
    @validator_messages = validator.messages
    if success
      return [validator.datasets, validator.chr_headers]
    else
      return nil
    end
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
        trait.import_job = self;
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
          Otu.create(:name => otu_name, :taxon => last_parent, :import_job => self)
          # refs
          # codings
        end
      end #end of datasets.each
  end

  
end
