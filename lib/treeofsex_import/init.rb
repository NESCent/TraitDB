#!/usr/bin/env ruby

#### TraitDB YML/CSV File validator ####

APP_ROOT = File.dirname(__FILE__) # a constant, based on the directory containing this file

$:.unshift APP_ROOT # puts the directory into the search path

# require 'validator' # loads once the validator.rb file
require 'import_template'

# Instantiate a template validator with the first argument
# which should be a YML file

import_template = TraitDB::ImportTemplate.new(ARGV[0])
puts import_template.template

# 
# validator = TreeOfSexImport::Validator.new(ARGV[0])
# validator.quantitative_header_start = "Chromosome number (female)"
# validator.quantitative_header_end = "c-value"
# validator.qualitative_header_start = "Predicted ploidy (1,2,3,4)"
# validator.qualitative_header_end = "Molecular basis (dosage,Y dominant,W dominant)"
# 
# results = validator.validate
# puts results
# results = validator.parse
# 
# results[:issues].each do |issue|
#   puts issue
# end
# 
# puts results[:issues].count
