require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test 'should redirect to select project' do
    sign_in(User.first)
    sign_out(User.first)
    get :index
    assert_response :redirect
  end
  test 'should show info content' do
    sign_in(User.first)
    sign_out(User.first)
    get :index, nil, {current_project_id: Project.first.id}
    assert_template 'info/index'
    assert_select 'h3', Project.first.name
  end
end
