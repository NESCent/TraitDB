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
IcznGroup.create(SEED_ICZN_GROUPS)

DisplayFormat.create([{name:''}, {name: 'integer'}, {name: 'float'}, {name: 'string'}])

