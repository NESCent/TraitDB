require 'test_helper'

class CsvImportConfigTest < ActiveSupport::TestCase
  test 'can create with file' do
    config_file = File.new(Rails.root + 'lib/traitdb_import/Sample.yml')
    assert config_file.size > 0, 'config file is empty'
    csv_import_config = CsvImportConfig.create(:config_file => config_file)
    assert csv_import_config, 'unable to create sample config'
    assert_equal 'Sample.yml', csv_import_config.config_file_file_name, 'file name is wrong'
  end
end
