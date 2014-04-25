require 'test_helper'

class SearchWithTraitSetsTest < ActionDispatch::IntegrationTest
  fixtures :projects, :taxa, :trait_sets
  test 'can select trait sets' do
    visit '/'
    # will be redirected to select project
    select projects(:project3).name, :from => 'id'
    click_on 'Select Project'
    visit '/search'
    print page.html
    select taxa(:animal).name, :from => 'kingdom_0'
    # Failing here because no javascript
    select trait_sets(:trait_set_demographic).name, :from => 'trait_set_level'
    select 'categorical', :from => 'trait_type'
  end
end
