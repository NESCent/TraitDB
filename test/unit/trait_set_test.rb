require 'test_helper'

class TraitSetTest < ActiveSupport::TestCase
  fixtures :trait_sets
  test 'Trait sets are hierarchical' do
    child = trait_sets(:trait_set_demographic_group_size)
    assert_equal trait_sets(:trait_set_demographic), child.parent_trait_set
  end
end
