require 'traitdb_import/import_template'
class CsvImportConfig < ActiveRecord::Base
  attr_accessible :config_file
  has_attached_file :config_file
  belongs_to :project
  belongs_to :user
  has_many :import_jobs
  validates_attachment_presence :config_file
  scope :by_project, lambda{|p| where(:project_id => p) unless p.nil?}

  def get_import_template
    TraitDB::ImportTemplate.new(config_file.path)
  end

  def update_name
    self.name = get_import_template.name
  end

  def generate_info(group_id)
    info = {}
    # Group is a trait_group
    trait_group = TraitGroup.find(group_id)
    t = get_import_template
    info[:taxonomy_columns] = t.taxonomy_columns.values
    info[:require_source] = t.trait_options['require_source']
    info[:categorical_traits] = []
    info[:continuous_traits] = []
    info[:metadata_columns] = t.metadata_columns.values

    # get prefixes
    source_prefix = t.trait_options['source_prefix']
    notes_prefix = t.trait_options['notes_prefix']

    t.categorical_trait_names_in_group(trait_group.name).each do |cat|
      info[:categorical_traits] << {
        :name => cat,
        :values => t.categorical_trait_values(cat),
        :source_name => "#{source_prefix}#{cat}",
        :notes_name => "#{notes_prefix}#{cat}"
      }
    end
    t.continuous_trait_names_in_group(trait_group.name).each do |con|
      info[:continuous_traits] << {
        :name => con,
        :format => t.continuous_trait_format(con),
        :source_name => "#{source_prefix}#{con}",
        :notes_name => "#{notes_prefix}#{con}"
      }
    end
    info
  end

  def generate_csv_template(group_id)
    # Group is a trait_group
    trait_group = TraitGroup.find(group_id)
    t = get_import_template

    output_csv_string = CSV.generate do |csv|
      headers = []
      headers += t.taxonomy_columns.values

      # get the source prefix
      source_prefix = t.trait_options['source_prefix']
      require_source = t.trait_options['require_source']

      t.categorical_trait_names_in_group(trait_group.name).each do |cat|
        headers << cat
        headers << "#{source_prefix}#{cat}" if require_source
      end
      t.continuous_trait_names_in_group(trait_group.name).each do |con|
        headers << con
        headers << "#{source_prefix}#{con}" if require_source
      end
      headers += t.metadata_columns.values
      csv << headers
      csv << []
    end
    output_csv_string
  end

  private

end
