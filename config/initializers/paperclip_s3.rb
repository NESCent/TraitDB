# Use s3 if specified in environment, but not in test environment
TraitDB::Application.config.use_s3 = !(ENV['TRAITDB_USE_S3'].nil?) && Rails.env != 'test'
