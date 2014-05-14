require 'test_helper'

class UploadControllerTest < ActionController::TestCase
  test 'can upload and download csv file' do
    sign_in(User.first)
    set_project(Project.first)

    get :index
    puts @response.body
    assert_template 'upload/index'
    assert_select 'input', 'dataset_csv_file'
  end
end
