require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get index" do
    sign_in User.first
    get :index, nil, {current_project_id: Project.first.id}
    assert_response :success
    assert_not_nil assigns(:iczn_groups)
    sign_out User.first
  end
end
