require 'test_helper'
require 'traitdb_import/downloader'
require 'tempfile'

class DownloaderTest < ActiveSupport::TestCase
  test "can download a file" do
    body = 'abc'
    url = 'http://www.example.com/file.yml'
    dest = Tempfile.new('downloader-test').path
    stub_request(:get, url).
      with(:headers => {'Accept'=>'*/*'}).
      to_return(:status => 200, :body => body, :headers => {})
    d = TraitDB::Downloader.new(url,dest)
    downloaded_contents = File.read(d.downloaded_file)
    assert_equal body, downloaded_contents, 'Downloaded body does not match mocked body'
  end

  test "fails with bad url" do
    url = 'nothttp://www.example.com/file.yml'
    dest = Tempfile.new('downloader-test').path
    d = TraitDB::Downloader.new(url,dest)
    assert_nil d.downloaded_file, 'Downloaded file should be nil with bad url'
  end

  test "fails with file not found" do
    body = 'Not found'
    url = 'http://www.example.com/file.yml'
    dest = Tempfile.new('downloader-test').path
    stub_request(:get, url).
      with(:headers => {'Accept'=>'*/*'}).
      to_return(:status => 404, :body => body, :headers => {})
    d = TraitDB::Downloader.new(url,dest)
    assert_nil d.downloaded_file, 'Downloaded file should be nil when 404 not found'
  end

  test "follows redirects" do
    url1 = 'http://www.example.com/source.yml'
    url2 = 'http://www.example.com/destination.yml'
    body = 'abc'
    dest = Tempfile.new('downloader-test').path

    stub_request(:get, url1).
      with(:headers => {'Accept'=>'*/*'}).
      to_return(:status => 301, :body => body, :headers => {'Location' => url2})
    stub_request(:get, url2).
      with(:headers => {'Accept'=>'*/*'}).
      to_return(:status => 200, :body => body, :headers => {})
    d = TraitDB::Downloader.new(url1,dest)
    downloaded_contents = File.read(d.downloaded_file)
    assert_equal body, downloaded_contents, 'Redirect failed'

  end
end
