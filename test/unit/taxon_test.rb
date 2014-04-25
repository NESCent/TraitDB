require 'test_helper'

class TaxonTest < ActiveSupport::TestCase
  fixtures :taxa, :projects, :iczn_groups, :import_jobs
  # test "the truth" do
  #   assert true
  # end

  test "Child taxa are in same project as parent" do
    import_job = import_jobs(:one)
    parent = taxa(:homo)
    child = Taxon.find_or_create_with_parent("child", parent, iczn_groups(:species), import_jobs(:one))
    assert_equal(child.project, import_job.project)
  end
end
