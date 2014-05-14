require 'test_helper'

class CsvImportConfigsControllerTest < ActionController::TestCase
  setup do
    sign_in(User.first)
    set_project(Project.first)
  end
  test 'can list import configs' do
    get :index
    assert_template 'csv_import_configs/index'
    assert_response :success
    assert_not_nil assigns(:configs)
  end
  test 'can upload import config' do
    # Keeping yml file out of fixtures directory because otherwise rails thinks its a fixture
    config_file = fixture_file_upload('../../lib/traitdb_import/Sample.yml')
    post :create, config: {:config_file => config_file}
    assert_redirected_to csv_import_configs_path
  end

end
