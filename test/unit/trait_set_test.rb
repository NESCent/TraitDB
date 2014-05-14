require 'test_helper'

class TraitSetTest < ActiveSupport::TestCase
  fixtures :trait_sets, :projects
  test 'Trait sets are hierarchical' do
    child = trait_sets(:trait_set_demographic_group_size)
    assert_equal trait_sets(:trait_set_demographic), child.parent_trait_set
  end

  test 'Can create nested trait sets' do
    path_names = ['Grandparent','Parent','Child']
    project = projects(:project3)
    child_set = TraitSet.find_or_create_with_path(project,path_names)
    assert_equal path_names.length - 1, child_set.level, 'Child level is wrong'
    assert_equal path_names[1], child_set.parent_trait_set.name, "Child's parent name is wrong"
  end
end
