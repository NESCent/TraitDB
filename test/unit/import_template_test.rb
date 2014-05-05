require 'test_helper'
require 'traitdb_import/import_template'
class ImportTemplateTest < ActiveSupport::TestCase
  test 'can read template file from filesystem' do
    file_path = Rails.root.join('lib','traitdb_import','Sample.yml')
    template = TraitDB::ImportTemplate.new(file_path)
    assert_not_empty template.name, 'Template should have a name'
  end

  test 'can read template file from http' do
    http_path = 'http://www.domain.com/Sample.yml'
    stub_request(:get, http_path).
      with(:headers => {'Accept'=>'*/*'}).
      to_return(:body => File.new(Rails.root.join('lib','traitdb_import','Sample.yml')), :status => 200)
    template = TraitDB::ImportTemplate.new(http_path)
    assert_not_empty template.name, 'Template should have a name'
  end
end