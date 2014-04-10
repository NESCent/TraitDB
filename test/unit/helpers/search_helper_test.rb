require 'test_helper'
require 'merge_trait_hashes'
class SearchHelperTest < ActionView::TestCase
  setup do
    @unmerged = [
      {
        1=>{ # trait.id 1
             :values=>[10=>200], # value_id, formatted_value
             :sources=>{10=>50}, # value_id is used to look up sources
             :notes=>nil,
             :value_matches=>{10=>true} # value with id 10 matched search criteria
        },
        2=> { #trait.id 2
              :values=>[20=>650], #trait_value.id 20, value 650
              :sources=>{20=>50}, # source for value with id 20 is 50
              :notes=>nil,
              :value_matches=>{20=>true} # value with id 10 matched search criteria
        }
      },
      {
        1=>{ # trait.id 1
             :values=>[11=>300], #trait_value.id 10, value 200
             :sources=>{11=>50}, # source for value with id 10 is 50
             :notes=>nil,
             :value_matches=>{11=>true} # value with id 10 matched search criteria
        },
        2=> { #trait.id 2
              :values=>[20=>650], #trait_value.id 20, value 650
              :sources=>{20=>50}, # source for value with id 20 is 50
              :notes=>nil,
              :value_matches=>{20=>true} # value with id 10 matched search criteria
        }
      }
    ]

    # We expect that the values will be averaged but rest will be from the first
    @expected_merged_avg =
      {
        1=>{ # trait.id 1
             :values=>[10=>250], # first id, averaged value
             :sources=>{10=>50}, # source for value with id 10 is 50
             :notes=>nil,
             :value_matches=>{10=>true} # value with id 10 matched search criteria
        },
        2=> { #trait.id 2
              :values=>[20=>650], #trait_value.id 20, value 650
              :sources=>{20=>50}, # source for value with id 20 is 50
              :notes=>nil,
              :value_matches=>{20=>true} # value with id 10 matched search criteria
        }
      }
  end

  test "merges trait hashes successfully" do
    merged = @unmerged.merge_trait_hashes(:avg)
    assert_equal @expected_merged_avg, merged, 'expected did not merge with average'
  end
end
