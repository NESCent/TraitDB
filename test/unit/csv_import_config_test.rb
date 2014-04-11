require 'test_helper'

class CsvImportConfigTest < ActiveSupport::TestCase
  test 'can create with file' do
    CsvImportConfig.create(:config_file => '')
  end
end
