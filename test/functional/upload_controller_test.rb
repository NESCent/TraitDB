require 'test_helper'

class UploadControllerTest < ActionController::TestCase
  test 'can get upload form' do
    sign_in(User.first)
    set_project(Project.first)

    get :index
    assert_template 'upload/index'
    assert_select 'input#dataset_csv_file', nil, 'Input element for CSV file upload missing'
  end
end
