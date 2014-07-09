require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :projects

  test "should get index" do
    # Only signing in so that is_authenticated_user? doesn't fail
    sign_in User.first
    sign_out User.first
    get :index, nil, {current_project_id: Project.first.id}
    assert_response :success
    assert_not_nil assigns(:iczn_groups)
  end

  test "should download all" do
    project = projects(:project3)
    assert_not_nil project
    iczn_group = project.iczn_groups.sorted.first
    assert_not_nil iczn_group
    taxon = iczn_group.taxa.sorted.first
    assert_not_nil taxon
    assert_includes iczn_group.projects, taxon.project
    params = {download_all: '1',
              select_all_traits: '1',
              include_references: '1',
              "#{iczn_group.name}[0]" => "#{taxon.id}",
              format: :csv
    }
    post :results, params, {current_project_id: project.id}
    assert assigns :results
    assert_response :success
    assert_template 'search/results'
    assert_equal @response.content_type, 'text/csv'
  end
end
