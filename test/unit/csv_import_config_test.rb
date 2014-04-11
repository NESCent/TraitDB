require 'test_helper'

class CsvImportConfigTest < ActiveSupport::TestCase
  test 'cannot create without file' do
    csv_import_config = CsvImportConfig.create()
    assert_not csv_import_config.valid?, 'config without file should not be valid'
  end
  test 'can create with file' do
    # doesn't seem to be a good way to set content type for testing
    config_file = File.new(Rails.root + 'lib/traitdb_import/Sample.yml')
    assert config_file.size > 0, 'config file is empty'
    csv_import_config = CsvImportConfig.create(:config_file => config_file)
    assert csv_import_config.valid?, 'unable to create sample config'
    assert_equal 'Sample.yml', csv_import_config.config_file_file_name, 'file name is wrong'
  end
  test 'rejects non-yaml files' do
    config_file = File.new(Rails.root + 'Gemfile')
    assert config_file.size > 0, 'Gemfile is empty'
    csv_import_config = CsvImportConfig.new(:config_file => config_file)
    csv_import_config.save
    assert_not csv_import_config.valid?, 'should not be valid unless yml file'
  end

end
