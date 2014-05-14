require 'test_helper'

class AboutControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test 'should redirect to select project' do
    sign_in(User.first)
    sign_out(User.first)
    get :index
    assert_response :redirect
  end
  test 'should show about content' do
    sign_in(User.first)
    sign_out(User.first)
    get :index, nil, {current_project_id: Project.first.id}
    assert_template 'about/index'
    assert_select 'h3', Project.first.name
  end
end
