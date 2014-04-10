require 'test_helper'
require 'merge_trait_hashes'
class SearchHelperTest < ActionView::TestCase
  setup do
    @unmerged = [
      {
        1=>{ # trait.id 1
             :values=>[{10=>200}], # value_id, formatted_value
             :sources=>{10=>50}, # value_id is used to look up sources
             :notes=>nil,
             :value_matches=>{10=>true}
        },
        2=> { #trait.id 2
              :values=>[{20=>650}],
              :sources=>{20=>50},
              :notes=>nil,
              :value_matches=>{20=>true}
        }
      },
      {
        1=>{ # trait.id 1
             :values=>[{11=>300}], #trait_value.id 10, value 200
             :sources=>{11=>50}, # source for value with id 10 is 50
             :notes=>nil,
             :value_matches=>{11=>true} # value with id 10 matched search criteria
        }
      },
      {
        3=> { #trait.id 3
              :values=>[{30=>650}],
              :sources=>{30=>50},
              :notes=>nil,
              :value_matches=>{30=>true}
        }
      }
    ]

    # We expect that the values will be averaged but rest will be from the first
    @expected_merged_avg_1 = {
        1=>{ # trait.id 1
             :values=>[{10=>250.0}], # first id, averaged value will be float
             :sources=>{10=>50}, # source for value with id 10 is 50
             :notes=>nil,
             :value_matches=>{10=>true} # value with id 10 matched search criteria
        }
      }
    @expected_max_1 = {
      1=>{ # trait.id 1
           :values=>[{11=>300}],
           :sources=>{10=>50},
           :notes=>nil,
           :value_matches=>{10=>true}
      }
    }
    @expected_min_1 = {
      1=>{ # trait.id 1
           :values=>[{10=>200}], #trait_value.id 10, value 200
           :sources=>{10=>50}, # source for value with id 10 is 50
           :notes=>nil,
           :value_matches=>{10=>true} # value with id 10 matched search criteria
      }
    }
    @expected_anything_2 = {
        2=> { #trait.id 2
              :values=>[{20=>650}], #trait_value.id 20, value 650
              :sources=>{20=>50}, # source for value with id 20 is 50
              :notes=>nil,
              :value_matches=>{20=>true} # value with id 10 matched search criteria
        }
      }
  end

  test "averages trait values" do
    merged = @unmerged.merge_trait_hashes(1, :avg)
    assert_equal @expected_merged_avg_1, merged, 'expected did not merge with average'
  end

  test "finds max trait values" do
    merged = @unmerged.merge_trait_hashes(1, :max)
    assert_equal @expected_max_1, merged, 'expected did not merge with max'
  end

  test "finds min trait values" do
    merged = @unmerged.merge_trait_hashes(1, :min)
    assert_equal @expected_min_1, merged, 'expected did not merge with min'
  end

  test "finds first trait values" do
    merged = @unmerged.merge_trait_hashes(1, :first)
    assert_equal @expected_min_1, merged, 'expected did not merge with first'
  end

  test "finds last trait values" do
    merged = @unmerged.merge_trait_hashes(1, :last)
    assert_equal @expected_max_1, merged, 'expected did not merge with last'
    merged = @unmerged.merge_trait_hashes(2, :first)
    assert_equal @expected_anything_2, merged, 'expected did not find only value in 2'
  end

end
