# Author: Dan Leehr
# 
# A validator is initialized with the path to a CSV file
# It reads the CSV file using the CSV gem and checks its
# contents for conformance with
# https://www.nescent.org/wg/treeofsex/images/4/4e/Instructions_for_import.docx
#
# The goal of this is to return a ruby object that contains the parsed data
# which can then be moved into NeXML or imported into a trait database

require 'csv'

class String
  def is_number?
    true if Float(self) rescue false
  end
end

module TraitDB
  class Validator
    attr_reader :datasets, :trait_headers
    # The template specifies what columns are valid
    # If we see a magic value in here it needs to be moved to the template
    def initialize(template=nil, path=nil)
      @template = template
      @filepath = path
      @validation_results = {:issues => [], :info => []}
      @parse_results = {:issues => [], :info => []}
      # initial empty collections
      @taxon_header_map = {}
      @trait_headers = {:continuous => [], :categorical => []}
      @trait_source_headers = []
      @trait_notes_headers = []
      @datasets = []

      if template.nil?
        @validation_results[:issues] << {
            :issue_description => "Unable to load import template",
            :suggested_solution => 'Make sure a template is selected.'
            }
      end
      if file_usable?
        @csvfile = nil
      else
        @validation_results[:issues] << {
            :issue_description => "Unable to load CSV File at #{path}",
            :suggested_solution => 'Make sure file uploads are configured correctly.'
            }
        @filepath = nil
      end
    end

    def validate
      read_csv_file
      if @csvfile.nil?
        @validation_results[:issues] << {
            :issue_description => 'Unable to read file as CSV',
            :suggested_solution => 'Make sure file is a valid Comma-Separated Values file'
        }
      end
      # read and check the column headers
      read_column_headers
      return @validation_results
    end

    def parse
      read_row_data
      @parse_results
    end

    private
  
    def read_csv_file
      @csvfile = CSV.read(@filepath,
                          :headers => true,
                          :header_converters => lambda{|f| f ? f.strip : nil},
                          :converters => lambda{|f| f ? f.strip : nil}
      )
    end
  
    def validate_simple_properties
      # Check for sizes of rows?
    end
  
    def read_column_headers
      # check for Taxon headers (Htg, Order, Family, Genus, Species)
      check_taxon_headers
      # Check for Continuous Trait Headers
      read_continuous_trait_headers
      # Check for Categorical Trait headers
      read_categorical_trait_headers
      # check for valid trait source headers
      read_trait_source_headers
      # check for valid trait notes headers
      read_trait_notes_headers
      true
    end
  
    # Checks for presence of the required headers for taxonomy
    # e.g. Higher taxonomic group, order,...
    def check_taxon_headers
      headers = @csvfile.headers()
      if headers.nil?
        @validation_results[:issues] << {:issue_description => 'Unable to read headers from CSV'}
        return
      end
      # Require at least one taxon header
      found_taxon_headers = (@template.taxonomy_columns.values) & headers
      puts "found_taxon_headers: #{found_taxon_headers}"
      if found_taxon_headers.empty?
        # No taxon headers found
        @validation_results[:issues] << {
          :issue_description => 'Missing taxon headers',
          :suggested_solution => "Make sure CSV file has headers for taxa '#{@template.taxonomy_columns.values.join(',')}'."
        }
      else
        # Found at least one taxon header in the CSV file that is described by the template
        # Need to reverse the hash so that we can look up an internal group name (e.g. 'htg')
        # based on the value that appears in the CSV file (e.g. 'Higher Taxonomic Group')
        # Also, only store mappings for values that were found in the CSV, since our template
        # may reference extra fields

        @taxon_header_map = @template.taxonomy_columns.reject{|k,v| !found_taxon_headers.include? v }.invert
        @validation_results[:info] << {:info => 'Taxon headers are valid'}
      end
    end
  
    # Checks if the CSV file contains the headers defined by the template
    # as those for continuous traits
    def read_continuous_trait_headers
      # Try to find all the names listed in the template
      # Note that headers appearing in the template but not the CSV will not be in the output data
      found_headers = @template.continuous_trait_column_names & @csvfile.headers
      @trait_headers[:continuous] += found_headers.map{|x|
        {:name => x,
         :groups => @template.groups_for_continuous_trait(x),
         :format => @template.continuous_trait_format(x)
        }
      }
      @validation_results[:info] << {:info => "Found #{found_headers.count} continuous trait headers"}
    end
  
    # Checks if the CSV file contains the headers defined by the template
    # as those for categorical traits
    def read_categorical_trait_headers
      # Try to find all the names listed in the template
      # This assumes the values are not embedded in the column name
      # Note that headers appearing in the template but not the CSV will not be in the output data
      found_headers = @template.categorical_trait_column_names & @csvfile.headers
      @trait_headers[:categorical] += found_headers.map{|x|
        {:name => x,
         :groups => @template.groups_for_categorical_trait(x),
         :format => @template.categorical_trait_format(x),
         :values => @template.categorical_trait_values(x)
        }
      }
      @validation_results[:info] << {:info => "Found #{found_headers.count} categorical trait headers"}
    end

    def read_trait_source_headers
      # Get the prefix from the template
      required = @template.trait_options['require_source']
      prefix = @template.trait_options['source_prefix'] # needs to be validated in the template reader
      if required
        # source is required, make sure this csv file contains it for each header
        all_trait_headers = (@trait_headers[:continuous] + @trait_headers[:categorical]).map{|x| x[:name]}
        expected_source_headers = all_trait_headers.map{|x| "#{prefix}#{x}"} # prefix each
        missing_headers = expected_source_headers - @csvfile.headers()
        if missing_headers.empty?
          # nothing missing
          @validation_results[:info] << {:info => 'Source headers are valid'}
          @trait_source_headers += expected_source_headers
        else
          # missing required source headers
          missing_headers.each do |missing|
            @validation_results[:issues] << {
              :issue_description => 'Missing expected source header',
              :suggested_solution => "Make sure CSV file has a column header named '#{missing}'."
            }
          end
        end
      end
    end

    def read_trait_notes_headers
      prefix = @template.trait_options['notes_prefix']
      if prefix
        all_trait_headers = (@trait_headers[:continuous] + @trait_headers[:categorical]).map{|x| x[:name]}
        possible_trait_notes_headers = all_trait_headers.map{|x| "#{prefix}#{x}"}
        @trait_notes_headers += possible_trait_notes_headers & @csvfile.headers()
        unless @trait_notes_headers.empty?
          # Found at least one notes header
          @validation_results[:info] << {:info => 'Found valid notes headers'}
        end
      end
    end

    def read_row_data
      @csvfile.each_with_index do |row, i|
        dataset = {}
        lineno = i + 2 # i is zero-indexed and the first line is headers
        problematic_row = false
        next if row.nil? || row.empty?
        # Datasets have
        # 1. taxa
        taxon_hash = row.to_hash.select{|k,v| @taxon_header_map.keys.include?(k)}
        next if taxon_hash.nil? || taxon_hash.empty?

        # Order is safe to assume on Ruby 1.9 and later
        dataset[:taxon] = Hash[[@taxon_header_map.values, taxon_hash.values].transpose]

        # 2. Continuous Traits
        # Each item must be a number or nil
        # build an array of hashes.  Hashes contain :name and :value.  :source will be added later if present
        continuous_trait_data = []
        row.to_hash.select{|k,v| @trait_headers[:continuous].map{|x| x[:name]}.include?(k)}.each do |k,v|
          next if v.nil?
          # Fail if the data is non-numeric
          if (v.is_number?)
            continuous_trait_data << { :name => k, :value => Float(v) }
          else
            problematic_row = true
            @parse_results[:issues] << {
                :issue_description => 'Non-numeric value in continuous data field',
                :row_location => lineno,
                :column_name => k,
                :row_name => dataset[:taxon],
                :column_location => @csvfile.headers.index(k),
                :suggested_solution => 'Provide a numeric value.'
            }
          end
        end

        # 3. Categorical Traits
        # The data items must be a subset of the values enumerated by the template
        # build an array of hashes.  Hashes contain :name and :values.  :source will be added later
        categorical_trait_data = []
        # Would be a good idea to collect all of the errors before failing
        row.to_hash.select{|k,v| @trait_headers[:categorical].map{|x| x[:name]}.include?(k)}.each do |name,data|
          next if data.nil?
          # split the data values
          separator = @template.trait_options['value_separator'] || '|'
          split_data_values = data.split(separator)
          allowed_data_values = @template.categorical_trait_values(name)
          if(split_data_values - allowed_data_values).empty?
            # Everything in the data was enumerated in the template
            categorical_trait_data << {:name => name, :values => split_data_values}
          else
            # found data in the CSV that wasn't specified by the template
            problematic_row = true
            split_data_values.each do |value|
              @parse_results[:issues] << {
                :issue_description => "Unrecognized value '#{value}' in categorical data field",
                :row_location => lineno,
                :column_name => name,
                :row_name => dataset[:taxon],
                :column_location => @csvfile.headers.index(name),
                :suggested_solution => "Acceptable values are #{allowed_data_values}"
              }
            end
          end
        end
      
        # 4. Metadata columns
        dataset[:metadata] = {}
        @template.metadata_columns.each do |k,v|
          dataset[:metadata][k] = row.to_hash[v] if row.to_hash.include?(v)
        end

        # 5. Sources for trait data
        # Warn if source required but no source provided
        if @template.trait_options['require_source']
          (continuous_trait_data + categorical_trait_data).each do |trait_data|
            # { :name => "chromosome number (female)", :value => 32.0 }
            expected_header_name = "#{@template.trait_options['source_prefix']}#{trait_data[:name]}"
            if row.to_hash[expected_header_name].nil? || row.to_hash[expected_header_name].empty?
              problematic_row = true
              @parse_results[:issues] << {
                :issue_description => "No source provided for #{trait_data[:name]}",
                :row_location => lineno,
                :column_name => expected_header_name,
                :row_name => dataset[:taxon],
                :column_location => @csvfile.headers.index(expected_header_name),
                :suggested_solution => 'Provide source information for this value'
              }
            end
          end
        end

        # Warn if source specified but no data
        row.to_hash.select{|k,v| @trait_source_headers.include?(k)}.each do |k,v|
          next if v.nil?
          # find the existing hash {:name => xx, :value => yy} to inject the source
          expected_name = k.sub(@template.trait_options['source_prefix'],'')
          trait_data_hash = (continuous_trait_data + categorical_trait_data).find{|q| q[:name] == expected_name }
          if trait_data_hash.nil?
            problematic_row = true
            @parse_results[:issues] << {
                :issue_description => "Source provided for #{expected_name} but no data exists for '#{expected_name}'",
                :row_location => lineno,
                :column_name => k,
                :row_name => dataset[:taxon],
                :column_location => @csvfile.headers.index(k),
                :suggested_solution => "Make sure data is valid for '#{expected_name}' or remove source info from '#{k}'"
            }
          else
            trait_data_hash[:source] = source_string_to_hash(v)
          end
        end
        dataset[:continuous_trait_data] = continuous_trait_data
        dataset[:categorical_trait_data] = categorical_trait_data

        # leaving off here, next up is notes.

        # 6. Trait Notes
        # Warn if notes but no data
        row.to_hash.select{|k,v| @trait_notes_headers.include?(k)}.each do |k,v|
          next if v.nil?
          # find the existing hash {:name => xx, :value => yy} to inject the source
          expected_name = k.sub(@template.trait_options['source_prefix'],'')
          trait_data_hash = (continuous_trait_data + categorical_trait_data).find{|q| q[:name] == expected_name }
          if trait_data_hash.nil? # have notes but no data.
            problematic_row = true
            @parse_results[:issues] << {
              :issue_description => "Notes provided for '#{expected_name}' but no data exists for '#{expected_name}'",
              :row_location => lineno,
              :column_name => k,
              :row_name => dataset[:taxon],
              :column_location => @csvfile.headers.index(k),
              :suggested_solution => "Make sure data is valid for '#{expected_name}' or remove notes from '#{k}'"
            }
          else
            trait_data_hash[:notes] = v
          end
        end
        unless problematic_row
          @datasets << dataset
        end
      end
    end

    def uri?(string)
      true if string.match(/^http/)
    end

    def source_string_to_hash(string)
      if uri?(string)
        {:url => string, :title => string}
      elsif string.match(/\|/)
        a = string.split('|')
        {:last_name => a[0], :first_name => a[1], :year => a[2], :title => a[3]}
      else
        {:title => string}
      end
    end
  
    def file_usable?
      return false unless @filepath
      return false unless File.exists?(@filepath)
      return false unless File.readable?(@filepath)
      return true
    end
  end
end
