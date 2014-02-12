# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Populate ICZN groups
# Levels are used to provide a sort order, with enough distance between to allow intermediate IcznGroups to be created later
IcznGroup.destroy_all
IcznGroup.create([
                   {name: 'kingdom',        level: 100},
                   {name: 'htg',            level: 200},
                   {name: 'order',          level: 300},
                   {name: 'family',         level: 400},
                   {name: 'subfamily',      level: 450},
                   {name: 'genus',          level: 500},
                   {name: 'species',        level: 600},
                   {name: 'population',     level: 650},
                   {name: 'species_author', level: 700},
                   {name: 'infraspecific',  level: 800}
                 ])

DisplayFormat.create([{name:''}, {name: 'integer'}, {name: 'float'}, {name: 'string'}])

