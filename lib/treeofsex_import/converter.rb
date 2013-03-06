# Author: Dan Leehr
# 
# A converter is initialized with an array of hashes, representing a
# Tree of Sex dataset parsed from CSV.  It generates an NeXML file using
# bio-nexml

require 'bio-nexml'
module TreeOfSexImport
  class Converter
    def initialize(chr_headers=nil,datasets=nil)
      @datasets = datasets
      @chr_headers = chr_headers
      @node_id_map = {}
      @chr_id_map = {}
      @states_id_map = {}
      if datasets_usable? && chr_headers
        puts '=== Initializing Converter'
      else
        puts '=== Unable to initialize'
      end
    
    end

    def convert
      # convert
      nexml = Bio::NeXML::Nexml.new
      otus =  nexml.create_otus()
      # Create characters
      continuous_characters = nexml.create_characters('Continuous', true, :label => 'Continuous Characters')

      @chr_headers[:quantitative].each do |chr_header|
        # make character definitions for each quantitative character
        chr = continuous_characters.format.create_char(nil, {:label => chr_header})
        @chr_id_map[chr_header] = chr.id
      end

      # For categorical, need states
      categorical_characters = nexml.create_characters('Standard', true, :label => 'Categorical Characters')

      @chr_headers[:qualitative].each do |chr_header|
        # make states for each chr_states
        # states is a set of states (yes/no are the states, but they are grouped together by the chr_name)
        states = categorical_characters.format.create_states({:label => chr_header[:chr_name]})
        chr_header[:chr_states].each{|s| states.create_state(s)}
        @states_id_map[chr_header[:chr_name]] = states.id

        # make character definitions for each categorical character
        chr = categorical_characters.format.create_char(states)
        @chr_id_map[chr_header[:chr_name]] = chr.id
      end

      @datasets.each do |d|
        taxon = d[:taxon]
        otu_name = "#{taxon[:genus].capitalize.strip} #{taxon[:species].capitalize.strip}"
        otu = otus.create_otu(:label => otu_name)
        # end taxon
      
        # continuous characters
        m = continuous_characters.matrix
        quantitative_data_array = d[:quantitative_data]
        unless quantitative_data_array.empty?
          r = m.create_row(:otu => otu)
          quantitative_data_array.each do |q|
            # Hashes contain :name, :source, and :value.
            # when characters is initialized, it has a matrix and a format
            # Good example for characters and matrix
            # http://www.nexml.org/nexml/examples/characters.xml

            char = continuous_characters.format.get_char_by_id(@chr_id_map[q[:name]])

            # The value must be a string.  Otherwise it is assumed to be an object with an id method
            cell = Bio::NeXML::ContinuousCell.new(:char => char, :value => q[:value].to_s)
            r.add_cell(cell)
          end

          # end quantitative_data_array
        end

        # continuous characters
        m = categorical_characters.matrix
        qualitative_data_array = d[:qualitative_data]
        unless qualitative_data_array.empty?
          r = m.create_row(:otu => otu)
          qualitative_data_array.each do |q|
            # Hashes contain :name, :source, and :values (array)
            # make a character
            # Look up the state id by the symbol and the chr id
            states = categorical_characters.format.get_states_by_id(@states_id_map[q[:name]])
            char = categorical_characters.format.get_char_by_id(@chr_id_map[q[:name]])
            cell_states = states.select {|s| q[:values].include?(s.symbol) }
            cell_states.each do |state|
              cell = Bio::NeXML::Cell.new(:char => char, :state => state)
              r.add_cell(cell)
            end
          end
        end
        #end qualitative_data_array

      end
      writer = Bio::NeXML::Writer.new()
      writer << otus
      writer << continuous_characters
      writer << categorical_characters

      writer.save('output.xml',true)
    end
  
    private
  
    def datasets_usable?
      return false unless @datasets
      return false if @datasets.empty?
      true
    end
  end
end