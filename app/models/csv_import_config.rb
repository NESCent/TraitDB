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

  def trait_group_names
    get_import_template.trait_group_names
  end

  def generate_info(group_name)
    info = {}
    t = get_import_template
    info[:taxonomy_columns] = t.taxonomy_columns.values
    info[:require_source] = t.trait_options['require_source']
    info[:categorical_traits] = []
    info[:continuous_traits] = []
    info[:metadata_columns] = t.metadata_columns.values

    # get prefixes
    source_prefix = t.trait_options['source_prefix']
    notes_prefix = t.trait_options['notes_prefix']

    t.categorical_trait_names_in_group(group_name).each do |cat|
      info[:categorical_traits] << {
        :name => cat,
        :values => t.categorical_trait_values(cat),
        :source_name => "#{source_prefix}#{cat}",
        :notes_name => "#{notes_prefix}#{cat}"
      }
    end
    t.continuous_trait_names_in_group(group_name).each do |con|
      info[:continuous_traits] << {
        :name => con,
        :format => t.continuous_trait_format(con),
        :source_name => "#{source_prefix}#{con}",
        :notes_name => "#{notes_prefix}#{con}"
      }
    end
    info
  end

  def all_column_headers
    trait_group_names.map{|g| column_headers(g)}.flatten.uniq
  end

  def column_headers(group_name)
    template = get_import_template
    headers = []
    headers += template.taxonomy_columns.values

    source_prefix = template.trait_options['source_prefix']
    require_source = template.trait_options['require_source']

    template.categorical_trait_names_in_group(group_name).each do |categorical_trait_name|
      headers << categorical_trait_name
      headers << "#{source_prefix}#{categorical_trait_name}" if require_source
    end
    template.continuous_trait_names_in_group(group_name).each do |continuous_trait_name|
      headers << continuous_trait_name
      headers << "#{source_prefix}#{continuous_trait_name}" if require_source
    end
    headers += template.metadata_columns.values
    headers
  end

  def generate_csv_template(group_name)
    CSV.generate do |csv|
      csv << column_headers(group_name)
      csv << [] # empty row
    end
  end

end
