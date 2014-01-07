#!/usr/bin/env ruby

#### TraitDB YML/CSV File validator ####

APP_ROOT = File.dirname(__FILE__) # a constant, based on the directory containing this file

$:.unshift APP_ROOT # puts the directory into the search path

require 'import_template'
require 'validator' # loads once the validator.rb file
require 'pp'

# Instantiate a template validator with the first argument
# which should be a YML file

if ARGV.length == 0
  puts "Usage: #{__FILE__} <config.yml> [<dataset.csv>]"
  exit -1
end


import_template = TraitDB::ImportTemplate.new(ARGV[0])

puts "Import Config Continuous Trait Names".center(80,'=')
PP.pp(import_template.continuous_trait_column_names)
puts "Import Config Categorical Trait Names".center(80,'=')
PP.pp(import_template.categorical_trait_column_names)

exit if ARGV.length < 2

# Validator takes a template and a path to a CSV file
validator = TraitDB::Validator.new(import_template, ARGV[1])
validation_results = validator.validate
puts "Validation Results".center(80,'=')
PP.pp(validation_results)

puts "Parse Results".center(80,'=')
parse_results = validator.parse
PP.pp(parse_results)

puts "Parse Issues ".center(80,'=')
parse_results[:issues].each do |issue|
  pp(issue)
end

puts "Datasets".center(80,'=')
puts ""
datasets = validator.datasets
PP.pp(datasets)
