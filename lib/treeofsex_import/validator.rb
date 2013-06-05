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

module TreeOfSexImport
  class Validator
    attr_reader :datasets, :chr_headers
    attr_accessor :quantitative_header_start, :quantitative_header_end
    attr_accessor :qualitative_header_start, :qualitative_header_end
    # parse results is not yet implemented
    # Constant Header column names, required
    TAXON_HEADERS = ["Higher taxonomic group", "Order", "Family", "Genus", "species"]
    TAXON_SYMBOLS = [:higher_taxonomic_group, :order, :family, :genus, :species]
    ENTRY_EMAIL_HEADER = "entry email"
    NOTES_COMMENTS_HEADER = "notes, comments"
  
    # Headers for character name columns are not predefined, but the parser
    # must know the first/last quantitative character header
    # and the first/last qualitative character header
  
    # Headers for source columns must consist of the prefix below, followed by a 
    # character name
    SOURCE_PREFIX = 'source: '

    # Headers for notes columns must consist of the prefix below, followed by a
    # character name
    NOTES_PREFIX = 'notes: '
  
    def initialize(path=nil)
      @filepath = path
      @validation_results = {:issues => [], :info => []}
      @parse_results = {:issues => [], :info => []}
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
                          :header_converters => lambda{|f| f.strip },
                          :converters => lambda{|f| f ? f.strip : nil}
      )
    end
  
    def validate_simple_properties
      # Check for sizes of rows?
    end
  
    def read_column_headers
      @chr_headers = {}
      # check for Taxon headers (Htg, Order, Family, Genus, Species)
      check_taxon_headers
      # Check for Quantitative Character headers
      read_quantitative_chr_headers
      # Check for Qualitative Character headers
      read_qualitative_chr_headers
      # Check for Data entry email address header
      check_entry_email_header
      # Check for valid notes/comments header
      check_notes_comments_header
      # check for valid Qualitative Character source headers
      read_quantitative_chr_source_headers
      # check for valid Quantitative Character source headers
      read_qualitative_chr_source_headers
      # check for valid Character notes headers
      read_chr_notes_headers
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
      # Quickly check if we're missing any taxon headers
      unless (TAXON_HEADERS-headers).empty?
        missing_headers = TAXON_HEADERS-headers
        missing_headers.each do |missing|
          @validation_results[:issues] << {
              :issue_description => 'Missing taxon Header',
              :suggested_solution => "Make sure CSV file has column header named '#{missing}'."
          }
        end
      end
    end
  
    # Checks if headers marked by quantitative_header_start - quantitative_header_end
    # are valid quantitative headers.  
    def read_quantitative_chr_headers
      headers = @csvfile.headers()
      first = headers.index(@quantitative_header_start)
      last = headers.index(@quantitative_header_end)
      if first.nil?
        @validation_results[:issues] << {
            :issue_description => "Did not find first designated quantitative header: #{@quantitative_header_start}",
            :suggested_solution => 'Verify the headers you specified for the import or check your CSV file for typos'
        }
      end
      if last.nil?
        @validation_results[:issues] << {
            :issue_description => "Did not find last designated quantitative header: #{@quantitative_header_end}",
            :suggested_solution => 'Verify the headers you specified for the import or check your CSV file for typos'
        }
      end
      if first && last
        quantitative_chr_range = Range.new(first, last)
        @chr_headers[:quantitative] = headers[quantitative_chr_range]
        if @chr_headers[:quantitative].uniq.length != @chr_headers[:quantitative].length
          @validation_results[:issues] << {
              :issue_description => 'Quantitative headers are not unique',
              :column_location => first,
              :suggested_solution => 'Correct the duplicate column headers in your CSV file'
          }
        end
      else
        @validation_results[:info] << {:info => 'Quantitative headers are valid'}
      end
    end
  
    # checks for valid qualitative character headers
    # 
    def read_qualitative_chr_headers
      headers = @csvfile.headers()
      first = headers.index(@qualitative_header_start)
      last = headers.index(@qualitative_header_end)
      if first.nil?
        @validation_results[:issues] << {
            :issue_description => "Did not find first designated qualitative header: #{@qualitative_header_start}",
            :suggested_solution => 'Verify the headers you specified for the import or check your CSV file for typos'
        }
      end
      if last.nil?
        @validation_results[:issues] << {
            :issue_description => "Did not find last designated qualitative header: #{@qualitative_header_end}",
            :suggested_solution => 'Verify the headers you specified for the import or check your CSV file for typos'
        }
      end
      if first && last
        qualitative_chr_range = Range.new(first, last)
        # found qualitative headers, now make sure each contains choices
        raw_chr_headers = headers[qualitative_chr_range]
        @chr_headers[:qualitative] = []
        raw_chr_headers.each_with_index do |raw_chr_header, i|
          # Test regex for character name (state1, state2, state3)
          regex = /\A(.+)\((.+)\)\z/
          matched = regex.match(raw_chr_header)
          if matched.nil?
            @validation_results[:issues] << {
                :issue_description => 'Bad format in qualitative character header',
                :column_name => raw_chr_header,
                :column_location => first + i,
                :suggested_solution => "Check your CSV file to make sure the qualitative character header matches the required format: 'name (value1, value2, value3)'"
            }
            next
          end
          # Build a chr_header hash with the names and array of possible states
          chr_header = { :raw_header_name => raw_chr_header, :chr_name => matched[1].strip, :chr_states => matched[2].split(',').map{|st| st.strip } }
          # make sure this isn't a duplicate
          unless @chr_headers[:qualitative].detect {|c| c[:chr_name] == chr_header[:chr_name] }.nil?
            @validation_results[:issues] << {
                :issue_description => 'Duplicate character state in header',
                :column_name => raw_chr_header,
                :column_location => first + i,
                :suggested_solution => 'Remove duplicates from the possible states listed in the header'
            }
            next
          end
          @chr_headers[:qualitative] << chr_header
        end
      end
    end
  
    def check_entry_email_header
      if @csvfile.headers.include?(ENTRY_EMAIL_HEADER)
        @validation_results[:info] << {:info => "#{ENTRY_EMAIL_HEADER} header valid"}
      else
        @validation_results[:issues] << {
            :issue_description => "Missing #{ENTRY_EMAIL_HEADER}", :column_name => ENTRY_EMAIL_HEADER,
            :suggested_solution => "Make sure your CSV file has a column for '#{ENTRY_EMAIL_HEADER}'"
        }
      end
    end
  
    def check_notes_comments_header
      if @csvfile.headers.include?(NOTES_COMMENTS_HEADER)
        @validation_results[:info] << {:info => "#{NOTES_COMMENTS_HEADER} header valid"}
      else
        @validation_results[:issues] << {:issue_description => "Missing #{NOTES_COMMENTS_HEADER}", :column_name => NOTES_COMMENTS_HEADER}
      end
    end
  
    # Checks if a source header exists for each quantitative header
    # @chr_headers[:quantitative] must be populated
    def read_quantitative_chr_source_headers
      headers = @csvfile.headers()
      first = headers.index("#{SOURCE_PREFIX}#{@quantitative_header_start}")
      last = headers.index("#{SOURCE_PREFIX}#{@quantitative_header_end}")
      if first.nil?
        @validation_results[:issues] << {
            :issue_description => 'Did not find first designated quantitative source header',
            :column_name => "#{SOURCE_PREFIX}#{@quantitative_header_start}",
            :suggested_solution => 'Verify the headers you specified for the import or check your CSV file for typos'
        }
      end
      if last.nil?
        @validation_results[:issues] << {
            :issue_description => 'Did not find last designated quantitative source header',
            :column_name => "#{SOURCE_PREFIX}#{@quantitative_header_end}",
            :suggested_solution => 'Verify the headers you specified for the import or check your CSV file for typos'
        }
      end
      if first && last
        quantitative_chr_source_range = Range.new(first, last)
        @quantitative_chr_source_headers = headers[quantitative_chr_source_range]

        # headers we expect, based on @chr_headers[:quantitative]
        expected_source_headers = @chr_headers[:quantitative].map{|h| "#{SOURCE_PREFIX}#{h}" }

        missing_source_headers = expected_source_headers - @quantitative_chr_source_headers
        missing_source_headers.each do |missing|
          @validation_results[:issues] << {
              :issue_description => 'Missing expected quantitative source header',
              :suggested_solution => "Make sure CSV file has a column header named '#{missing}'."
          }
        end
        extra_source_headers = @quantitative_chr_source_headers - expected_source_headers
        extra_source_headers.each do |extra|
          @validation_results[:issues] << {
              :issue_description => "Found extra quantitative source header: '#{extra}'",
              :column_name => extra,
              :suggested_solution => 'Remove extra header or correct the import columns you specified'
          }
        end
        if missing_source_headers.empty? && extra_source_headers.empty?
          @validation_results[:info] << {:info => 'Quantitative source headers are valid'}
        end
      end
    end
  
    def read_qualitative_chr_source_headers
      headers = @csvfile.headers()
      first = headers.index("#{SOURCE_PREFIX}#{@qualitative_header_start}")
      last = headers.index("#{SOURCE_PREFIX}#{@qualitative_header_end}")
      if first.nil?
        @validation_results[:issues] << {
            :issue_description => 'Did not find first designated qualitative source header',
            :column_name => "#{SOURCE_PREFIX}#{@qualitative_header_start}",
            :suggested_solution => 'Verify the headers you specified for the import or check your CSV file for typos'
        }
      end
      if last.nil?
        @validation_results[:issues] << {
            :issue_description => 'Did not find last designated qualitative source header',
            :column_name => "#{SOURCE_PREFIX}#{@qualitative_header_end}",
            :suggested_solution => 'Verify the headers you specified for the import or check your CSV file for typos'
        }

      end
      if first && last
        @qualitative_chr_source_range = Range.new(first, last)
        # Remember, for qualitative headers, the possible choices are in the header
        # and captured in the @qualitative_chr_header hashes via :raw_header_name
        @qualitative_chr_source_headers = headers[@qualitative_chr_source_range]

        # headers we expect, based on @chr_headers[:qualitative]
        expected_source_headers = @chr_headers[:qualitative].map{|h| "#{SOURCE_PREFIX}#{h[:raw_header_name]}" }
        missing_source_headers = expected_source_headers - @qualitative_chr_source_headers
        missing_source_headers.each do |missing|
          @validation_results[:issues] << {
              :issue_description => 'Missing expected qualitative source header',
              :suggested_solution => "Make sure CSV file has a column header named '#{missing}'."
          }
        end
        extra_source_headers = @qualitative_chr_source_headers - expected_source_headers
        extra_source_headers.each do |extra|
          @validation_results[:issues] << {
              :issue_description => 'Found extra qualitative source header',
              :column_name => extra,
              :suggested_solution => 'Remove extra header or correct the import columns you specified'
          }
        end
        if missing_source_headers.empty? && extra_source_headers.empty?
          @validation_results[:info] << {:info => 'Qualitative source headers are valid'}
        end
      end
    end

    def read_chr_notes_headers
      @qualitative_chr_notes_headers = []
      @quantitative_chr_notes_headers = []
      @csvfile.headers().select{|header| header.index(NOTES_PREFIX) == 0}.each do |header|
        if @chr_headers[:quantitative].include? header.sub(NOTES_PREFIX,'')
          @quantitative_chr_notes_headers << header
        elsif @chr_headers[:qualitative].map{|x| x[:raw_header_name]}.include? header.sub(NOTES_PREFIX,'')
          @qualitative_chr_notes_headers << header
        else
          @validation_results[:issues] << {
            :issue_description => 'Found extra notes header',
            :column_name => header,
            :suggested_solution => 'Remove extra header or correct the import columns you specified'
          }
        end
      end
    end

    def read_row_data
      @datasets = []
      # map the raw names to the output names for looking up
      qualitative_chr_header_map = {}
      @chr_headers[:qualitative].each do |h|
        qualitative_chr_header_map[h[:raw_header_name]] = h[:chr_name]
      end
      @csvfile.each_with_index do |row, i|
        dataset = {}
        lineno = i + 2 # i is zero-indexed and the first line is headers
        problematic_row = false
        next if row.nil? || row.empty?
        # Datasets have
        # 1. taxa
        taxon_hash = row.to_hash.select{|k,v| TAXON_HEADERS.include?(k)}
        next if taxon_hash.nil? || taxon_hash.empty?
        # Need to make sure symbols are ordered the same way
        dataset[:taxon] = Hash[[TAXON_SYMBOLS, taxon_hash.values].transpose]
        # Need to symbolicate taxon headers
        # Species names have rules for -1, -2
        # How are these actually implemented?
        
        # species author, infraspecific?

        # 2. quantitative chars
        # Each item must be a number or nil
        # build an array of hashes.  Hashes contain :name and :value.  :source will be added later
        quantitative_data_array = []
        # only examine the 
        row.to_hash.select{|k,v| @chr_headers[:quantitative].include?(k)}.each do |k,v|
          next if v.nil?
          # Fail if the data is non-numeric
          if (v.is_number?)
            quantitative_data_array << { :name => k, :value => Float(v) }
          else
            problematic_row = true
            @parse_results[:issues] << {
                :issue_description => 'Non-numeric value in quantitative data field',
                :row_location => lineno,
                :column_name => k,
                :row_name => dataset[:taxon],
                :column_location => @csvfile.headers.index(k),
                :suggested_solution => 'Provide a numeric value.'
            }
          end
        end

        # 3. qualitative chars
        # Headers include the valid state names for the data
        # The data items must be a subset of the values enumerated in the headers
        # build an array of hashes.  Hashes contain :name and :values.  :source will be added later
        qualitative_data_array = []
        # Would be a good idea to collect all of the errors before failing
        row.to_hash.select{|k,v| @chr_headers[:qualitative].map{|h| h[:raw_header_name]}.include?(k)}.each do |k,v|
          next if v.nil?
          # Look up the new key based on the old key
          key_index = @chr_headers[:qualitative].find_index{|h| h[:raw_header_name] == k }
          name = @chr_headers[:qualitative][key_index][:chr_name]
          # split the data values
          split_values = v.split("|")
          # each data value must exist in the array of possible values (chr_states)
          if(split_values - @chr_headers[:qualitative][key_index][:chr_states]).empty?
            # all values in the cell exist in the header
            qualitative_data_array << { :name => name, :values => split_values }
          else
            split_values.each do |split_value|
              problematic_row = true
              @parse_results[:issues] << {
                  :issue_description => "Unrecognized value '#{split_value}' in qualitative data field",
                  :row_location => lineno,
                  :column_name => k,
                  :row_name => dataset[:taxon],
                  :column_location => @csvfile.headers.index(k),
                  :suggested_solution => "Acceptable values are #{@chr_headers[:qualitative][key_index][:chr_states]}"
              }
            end
          end
        end
      
        # 4. Email Entry
        dataset[:email_entry] = row[ENTRY_EMAIL_HEADER]
        if dataset[:email_entry].nil?
          problematic_row = true
          @parse_results[:issues] << {
              :issue_description => "Missing #{ENTRY_EMAIL_HEADER}",
              :row_location => lineno,
              :column_name => ENTRY_EMAIL_HEADER,
              :row_name => dataset[:taxon],
              :column_location => @csvfile.headers.index(ENTRY_EMAIL_HEADER),
              :suggested_solution => 'Provide a valid email address'
          }
        end

        # 5. Notes/comments
        dataset[:notes_comments] = row[NOTES_COMMENTS_HEADER]

        # 6. Sources - for quantitative data
        # Warn if no source is specified
        quantitative_data_array.each do |quantitative_data_hash|
          expected_header_name = "#{SOURCE_PREFIX}#{quantitative_data_hash[:name]}"
          if row.to_hash[expected_header_name].nil? || row.to_hash[expected_header_name].empty?
            problematic_row = true
            @parse_results[:issues] << {
              :issue_description => "No source provided for #{quantitative_data_hash[:name]}",
              :row_location => lineno,
              :column_name => expected_header_name,
              :row_name => dataset[:taxon],
              :column_location => @csvfile.headers.index(expected_header_name),
              :suggested_solution => 'Provide source information for this value'
            }
          end
        end
        # Warn if source specified but no data
        row.to_hash.select{|k,v| @quantitative_chr_source_headers.include?(k)}.each do |k,v|
          next if v.nil?
          # find the existing hash {:name => xx, :value => yy} to inject the source
          expected_name = k.sub(SOURCE_PREFIX,"")
          quantitative_data_hash = quantitative_data_array.find{|q| q[:name] == expected_name }
          if quantitative_data_hash.nil?
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
            quantitative_data_hash[:source] = source_string_to_hash(v)
          end
        end
        dataset[:quantitative_data] = quantitative_data_array
      
        # 7. Sources - for qualitative data
        # Warn if no source is specified
        qualitative_data_array.each do |qualitative_data_hash|
          expected_header_name = "#{SOURCE_PREFIX}#{qualitative_chr_header_map.find{|k,v| v == qualitative_data_hash[:name]}.first}"
          if row.to_hash[expected_header_name].nil? || row.to_hash[expected_header_name].empty?
            problematic_row = true
            @parse_results[:issues] << {
              :issue_description => "No source provided for #{qualitative_data_hash[:name]}",
              :row_location => lineno,
              :column_name => expected_header_name,
              :row_name => dataset[:taxon],
              :column_location => @csvfile.headers.index(expected_header_name),
              :suggested_solution => 'Provide source information for this value'
            }
          end
        end
        # Warn if source specified but no data
        row.to_hash.select{|k,v| @qualitative_chr_source_headers.include?(k)}.each do |k,v|
          next if v.nil?
          # find the existing hash {:name => xx, :value => yy} to inject the source
          # qualitative :names are trimmed.  Don't have (val1,val2,val3) in them.
          # But the qualitative_chr_header_map does
          expected_name = qualitative_chr_header_map[k.sub(SOURCE_PREFIX,"")]
          if expected_name.nil?
            problematic_row = true
            @parse_results[:issues] << {
                :issue_description => "Source header name '#{k}' is not a valid header name",
                :row_location => lineno,
                :column_name => k,
                :row_name => dataset[:taxon],
                :column_location => @csvfile.headers.index(k),
                :suggested_solution => "Make sure header '#{k}' begins with '#{SOURCE_PREFIX}' and ends with a qualitative header name"
            }
          end
          qualitative_data_hash = qualitative_data_array.find{|q| q[:name] == expected_name }
          if qualitative_data_hash.nil?
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
            qualitative_data_hash[:source] = source_string_to_hash(v)
          end
        end
        dataset[:qualitative_data] = qualitative_data_array

        # 8. Notes - for quantitative data
        # Warn if notes but no data
        row.to_hash.select{|k,v| @quantitative_chr_notes_headers.include?(k)}.each do |k,v|
          next if v.nil?
          # find the existing hash {:name => xx, :value => yy} to inject the source
          expected_name = k.sub(NOTES_PREFIX,'')
          quantitative_data_hash = quantitative_data_array.find{|q| q[:name] == expected_name }
          if quantitative_data_hash.nil? # have notes but no data.  Should this be tolerated?
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
            quantitative_data_hash[:notes] = v
          end
        end
        # 9. Notes - for qualitative data
        # Warn if notes but no data
        row.to_hash.select{|k,v| @qualitative_chr_notes_headers.include?(k)}.each do |k,v| # k is the column name
          next if v.nil?
          # find the existing hash {:name => xx, :value => yy} to inject the source
          # qualitative :names are trimmed.  Don't have (val1,val2,val3) in them.
          # But the qualitative_chr_header_map does
          expected_name = qualitative_chr_header_map[k.sub(NOTES_PREFIX,"")]
          qualitative_data_hash = qualitative_data_array.find{|q| q[:name] == expected_name }
          if qualitative_data_hash.nil?
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
            qualitative_data_hash[:notes] = v
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
