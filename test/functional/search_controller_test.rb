require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, nil, {current_project_id: Project.first.id}
    assert_response :success
    assert_not_nil assigns(:iczn_groups)
  end
end
