require 'test_helper'
include ActionDispatch::TestProcess

class CsvDatasetTest < ActiveSupport::TestCase
  setup do
    @dataset = CsvDataset.create(:csv_file => fixture_file_upload("#{File.join('data','20plants.csv')}"))
  end

  test "has file name" do
    assert_not_nil @dataset.file_name
    assert_equal '20plants.csv', @dataset.file_name
  end
end
