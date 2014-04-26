require 'test_helper'

class SearchWithTraitSetsTest < ActionDispatch::IntegrationTest
  fixtures :projects, :taxa, :trait_sets, :categorical_traits
  setup do
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.default_wait_time = 5
  end
  test 'can select trait sets' do
    visit '/'
    # will be redirected to select project
    select projects(:project3).name, :from => 'id'
    click_on 'Select Project'
    visit '/search'
    select taxa(:animal).name, :from => 'kingdom_0'
    select trait_sets(:trait_set_reproductive).name, :from => 'level0_0'
    select trait_sets(:trait_set_reproductive_sub).name, :from => 'level1_0'
    select 'Continuous', :from => 'trait_type_0'
    select 'Categorical', :from => 'trait_type_0'
    select categorical_traits(:categorical_trait2).name, :from => 'trait_name_0'
    select trait_sets(:trait_set_demographic).name, :from => 'level0_0'
    select trait_sets(:trait_set_demographic_group_size).name, :from => 'level1_0'
    select 'Continuous', :from => 'trait_type_0'
    select 'Categorical', :from => 'trait_type_0'
    select categorical_traits(:categorical_trait1).name, :from => 'trait_name_0'
  end
end
