require 'test_helper'

class OtuTest < ActiveSupport::TestCase
  test 'it creates names from genus and species' do
    o = Otu.first
    genus = Taxon.find_by_name('Homo')
    species = Taxon.find_by_name('sapiens')
    subspecies = Taxon.find_by_name('ss1')
    genus.iczn_group = IcznGroup.find_by_name('genus')
    genus.save
    species.iczn_group = IcznGroup.find_by_name('species')
    species.save
    subspecies.iczn_group = IcznGroup.find_by_name('subspecies')
    subspecies.save

    o.taxa << species
    o.taxa << genus
    o.taxa << subspecies

    # name should be updated
    assert_equal "#{genus.name} #{species.name}", o.name
  end
end
