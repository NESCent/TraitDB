require 'traitdb_import/import_template'
class CsvImportConfig < ActiveRecord::Base
  attr_accessible :config_file
  if TraitDB::Application.config.use_s3
    has_attached_file :config_file,
                      :storage => :s3,
                      :s3_credentials => Rails.root.join('config','s3_credentials.yml')
  else
    has_attached_file :config_file
  end
  belongs_to :project
  belongs_to :user
  has_many :import_jobs
  validates_attachment_presence :config_file
  # As of paperclip 4, attachments must have content type, file name, or opt out
  validates_attachment_file_name :config_file, :matches => [/yml\Z/, /yaml\Z/]
  scope :by_project, lambda{|p| where(:project_id => p) unless p.nil?}

  def get_import_template
    TraitDB::ImportTemplate.new(get_local_file)
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

    if group_name.nil?
      continuous_traits = t.continuous_trait_names_ungrouped
      categorical_traits = t.categorical_trait_names_ungrouped
    else
      continuous_traits = t.continuous_trait_names_in_group(group_name)
      categorical_traits = t.categorical_trait_names_in_group(group_name)
    end

    categorical_traits.each do |cat|
      trait = {
        :name => cat,
        :values => t.categorical_trait_values(cat),
      }
      trait[:source_name] = "#{source_prefix}#{cat}" if source_prefix
      trait[:notes_name] = "#{notes_prefix}#{cat}" if notes_prefix
      info[:categorical_traits] << trait
    end
    continuous_traits.each do |con|
       trait = {
        :name => con,
        :format => t.continuous_trait_format(con),
      }
      trait[:source_name] = "#{source_prefix}#{con}" if source_prefix
      trait[:notes_name] = "#{notes_prefix}#{con}" if notes_prefix
      info[:continuous_traits] << trait
    end
    info
  end

  def generate_csv_template(group_name)
    template = get_import_template
    CSV.generate do |csv|
      if group_name
        csv << template.column_headers(group_name)
      else
        csv << template.all_column_headers
      end
      csv << [] # empty row
    end
  end

  def get_local_file
    # If the file is local, just return the file system path
    if File.exists?(config_file.path)
      return config_file.path
    else
      cache_file
      return @cached_file.file
    end
  end

  def file_name
    config_file_file_name
  end

  def file_cached?
    return false if @cached_file.nil?
    true
  end
  private

  def cache_file
    unless file_cached?
      @cached_file = CachedFile.new(config_file.url)
    end
  end

end
