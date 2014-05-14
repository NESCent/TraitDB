require 'test_helper'

class OtuTest < ActiveSupport::TestCase
  fixtures :otus, :taxa, :projects, :iczn_groups, :import_jobs
  test 'it creates names from genus and species' do
    o = otus(:otu1)
    genus = taxa(:homo)
    species = taxa(:sapiens)
    subspecies = taxa(:ss1)

    o.taxa << species
    o.taxa << genus
    o.taxa << subspecies

    # name should be updated
    assert_equal "#{genus.name} #{species.name}", o.name
  end
end
