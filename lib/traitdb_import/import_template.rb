require 'yaml'

module TraitDB
  class ImportTemplate
    DEFAULT_SET_DELIMITER = '::'
    def initialize(path=nil)
      @template_file = path
      if file_usable?
        read_template
      else
        @template_file = nil
        raise "Unable to load template file at #{path}"
      end
    end
    
    # template name
    def name
      @config['template_name']
    end
    
    # taxonomy
    def taxonomy_columns # a hash that maps constants to the CSV column names, reverse it to get a map the other way
      @config['taxonomy_columns']
    end

    # metadata
    def metadata_columns # a hash that maps constants to the CSV column names, reverse it to get a map the other way
      @config['metadata_columns'] || {}
    end

    # options
    def trait_options # a hash that includes things like source_prefix, require_source, and notes_prefix
      @config['trait_options'] || {}
    end

    def trait_sets?
      @config['trait_sets'].nil? ? false : true
    end

    # trait sets
    def trait_set(path=[], tree=@config)
      # path will be a list of names to follow
      # tree must be a hash
      if tree.nil?
        # dead end
        return {}
      elsif path.length == 0
        # Terminal
        tree
      else
        # slice off the first element in the path and return the subtree
        sliced_path = path[1..-1]
        subtree = tree['trait_sets'].find{|x| x && x['name'] == path[0]}
        trait_set(sliced_path,subtree)
      end
    end

    def trait_set_names(path=[], tree=@config)
      trait_set(path, tree)['trait_sets'].map{|x| x['name']}
    end

    def trait_set_continuous_traits(path=[], tree=@config)
      trait_set(path, tree)['continuous_trait_columns']
    end

    def trait_set_categorical_traits(path=[], tree=@config)
      trait_set(path, tree)['categorical_trait_columns']
    end

    # returns array of path components
    def trait_set_qualified_continuous_trait_names
      trait_set_qualified_trait_names([], @config, 'continuous_trait_columns')
    end

    # returns array of path components
    def trait_set_qualified_categorical_trait_names
      trait_set_qualified_trait_names([], @config, 'categorical_trait_columns')
    end

    def trait_path_from_column(column_name)
      column_name.split(delimiter)
    end

    # trait names
    def categorical_trait_column_names
      if trait_sets?
        # get name array paths, and join with delimiter
        trait_set_qualified_categorical_trait_names.map{|n| n.join(delimiter) }
      else
        @config['categorical_trait_columns'].map{|x| x['name'] }
      end
    end

    def continuous_trait_column_names
      if trait_sets?
        # get name array paths, and join with delimiter
        trait_set_qualified_continuous_trait_names.map{|n| n.join(delimiter) }
      else
        @config['continuous_trait_columns'].map{|x| x['name'] }
      end
    end

    def continuous_trait_names_ungrouped
      if trait_sets?
        names = []
        trait_set_qualified_continuous_trait_names.each do |qname|
          trait = continuous(qname.join(delimiter))
          if trait
            names << qname.join(delimiter)
          end
        end
        names
      else
        @config['continuous_trait_columns'].map{|x| x['name']}
      end
    end

    def categorical_trait_names_ungrouped
      if trait_sets?
        names = []
        trait_set_qualified_categorical_trait_names.each do |qname|
          trait = categorical(qname.join(delimiter))
          if trait
            names << qname.join(delimiter)
          end
        end
        names
      else
        @config['categorical_trait_columns'].map{|x| x['name']}
      end
    end

    def categorical_trait_names_in_group(group_name)
      if trait_sets?
        names = []
        trait_set_qualified_categorical_trait_names.each do |qname|
          trait = categorical(qname.join(delimiter))
          if trait
            names << qname.join(delimiter) if trait['groups'].include? group_name
          end
        end
        names
      else
        @config['categorical_trait_columns'].select{|x| x['groups'].include? group_name}.map{|x| x['name']}
      end
    end
    
    def continuous_trait_names_in_group(group_name)
      if trait_sets?
        names = []
        trait_set_qualified_continuous_trait_names.each do |qname|
          trait = continuous(qname.join(delimiter))
          if trait
            names << qname.join(delimiter) if trait['groups'].include? group_name
          end

        end
        names
      else
        @config['continuous_trait_columns'].select{|x| x['groups'].include? group_name}.map{|x| x['name']}
      end
    end

    # trait values
    def categorical_trait_values(trait_name)
      categorical(trait_name)['values']
    end
    
    # groups
    def trait_group_names
      @config['trait_groups'].map{|x| x['name']}
    end

    def trait_group_rank(group_name)
      @config['trait_groups'].find{|x| x && x['name'] == group_name}['taxonomic_rank']
    end

    def trait_group_taxon_name(group_name)
      @config['trait_groups'].find{|x| x && x['name'] == group_name}['taxon_name']
    end

    def groups_for_categorical_trait(trait_name)
      t = categorical(trait_name)
      t.nil? ? [] : t['groups']
    end
    
    def groups_for_continuous_trait(trait_name)
      t = continuous(trait_name)
      t.nil? ? [] : t['groups']
    end
    
    # formats
    def continuous_trait_format(trait_name)
      t = continuous(trait_name)
      t.nil? ? [] : t['format']
    end

    def categorical_trait_format(trait_name)
      t = categorical(trait_name)
      t.nil? ? [] : t['format']
    end

    def column_headers(group_name)
      headers = []
      headers += taxonomy_columns.values

      source_prefix = trait_options['source_prefix']
      require_source = trait_options['require_source']

      categorical_trait_names_in_group(group_name).each do |categorical_trait_name|
        headers << categorical_trait_name
        headers << "#{source_prefix}#{categorical_trait_name}" if require_source
      end
      continuous_trait_names_in_group(group_name).each do |continuous_trait_name|
        headers << continuous_trait_name
        headers << "#{source_prefix}#{continuous_trait_name}" if require_source
      end
      headers += metadata_columns.values
      headers
    end

    def all_column_headers
      headers = []
      headers += taxonomy_columns.values

      source_prefix = trait_options['source_prefix']
      require_source = trait_options['require_source']

      categorical_trait_names_ungrouped.each do |categorical_trait_name|
        headers << categorical_trait_name
        headers << "#{source_prefix}#{categorical_trait_name}" if require_source
      end
      continuous_trait_names_ungrouped.each do |continuous_trait_name|
        headers << continuous_trait_name
        headers << "#{source_prefix}#{continuous_trait_name}" if require_source
      end
      headers += metadata_columns.values
      headers
    end

    private

    def delimiter
      trait_options['set_delimiter'] || DEFAULT_SET_DELIMITER
    end

    def continuous(trait_name)
      if trait_sets?
        path = trait_path_from_column(trait_name)
        t = trait_set_continuous_traits(path[0..-2])
        trait_name = path[-1] #reassigning the name
      else
        t = @config['continuous_trait_columns']
      end
      t && t.find{|x| x && x['name'] == trait_name}
    end

    def categorical(trait_name)
      if trait_sets?
        path = trait_path_from_column(trait_name)
        t = trait_set_categorical_traits(path[0..-2])
        trait_name = path[-1] #reassigning the name
      else
        t = @config['categorical_trait_columns']
      end
      t && t.find{|x| x && x['name'] == trait_name}
    end

    # returns arrays of path components
    def trait_set_qualified_trait_names(prefixes, tree, terminal_path)
      # Build up an array of paths
      # start at the root
      if tree['trait_sets']
        # have trait sets, recurse!
        paths = []
        tree['trait_sets'].each do |t|
          paths += trait_set_qualified_trait_names(prefixes + [t['name']], t, terminal_path)
        end
        paths
      elsif tree[terminal_path]
        # At the tip, return the column names
        names = tree[terminal_path].map{|x| x['name']}
        names.map{|n| prefixes + [n]}
      else
        []
      end
    end

    def file_usable?
      return false unless @template_file
      return false unless File.exists?(@template_file)
      return false unless File.readable?(@template_file)
      return true
    end

    def read_template
      root_object = YAML.load_file(@template_file)
      @config = root_object['traitdb_spreadsheet_template']
      @config['continuous_trait_columns'] ||= []
      @config['categorical_trait_columns'] ||= []
      @config['trait_groups'] ||= []
    end
    
  end
end

