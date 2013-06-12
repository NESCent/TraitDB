require 'yaml'

module TraitDB
  class ImportTemplate
    def initialize(path=nil)
      @template_file = path
      if file_usable?
        read_template
      else
        @template_file = nil
        raise "Unable to load template file at #{path}"
      end
    end
    
    def name
      @template['template_name']
    end
    
    def taxonomy_columns # a hash that maps constants to the CSV column names, reverse it to get a map the other way
      @template['taxonomy_columns']
    end

    def metadata_columns # a hash that maps constants to the CSV column names, reverse it to get a map the other way
      @template['metadata_columns']
    end

    def trait_options # a hash that includes things like source_prefix, require_source, and notes_prefix
      @template['trait_options']
    end
    
    def trait_groups
      @template['trait_groups']
    end
    
    def categorical_trait_names
      @template['categorical_trait_columns'].map{|x| x['name'] }
    end
    
    def categorical_trait_values(trait_name)
      @template['categorical_trait_columns'].find{|x| x['name'] == trait_name}['values']
    end
    
    def continuous_trait_names
      @template['continuous_trait_columns'].map{|x| x['name'] }
    end
    
    def categorical_trait_names_in_group(group_name)
      @template['categorical_trait_columns'].select{|x| x['groups'].include? group_name}.map{|x| x['name']}
    end
    
    def continuous_trait_names_in_group(group_name)
      @template['continuous_trait_columns'].select{|x| x['groups'].include? group_name}.map{|x| x['name']}
    end
    
    def groups_for_categorical_trait(trait_name)
      @template['categorical_trait_columns'].find{|x| x['name'] == trait_name}['groups']
    end
    
    def groups_for_continuous_trait(trait_name)
      @template['continuous_trait_columns'].find{|x| x['name'] == trait_name}['groups']
    end

    private

    def file_usable?
      return false unless @template_file
      return false unless File.exists?(@template_file)
      return false unless File.readable?(@template_file)
      return true
    end

    def read_template
      root_object = YAML.load_file(@template_file)
      @template = root_object['traitdb_spreadsheet_template']
    end
    
  end
end

