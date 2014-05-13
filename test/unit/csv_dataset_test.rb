require 'test_helper'

class CsvDatasetTest < ActiveSupport::TestCase
  setup do
    @dataset = csv_datasets(:one)
    @file = File.new(Rails.root.join('test','data','20plants.csv'))
    @dataset.csv_file = @file
  end

  test "has file name" do
    assert_not_nil @dataset.file_name
    assert_equal '20plants.csv', @dataset.file_name
  end

  test "provides local filesystem path" do
    puts @dataset.local_filesystem_path
    assert_not_empty @dataset.local_filesystem_path, 'path should not be empty'
  end
end
