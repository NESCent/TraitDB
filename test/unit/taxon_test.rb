require 'test_helper'

class TaxonTest < ActiveSupport::TestCase
  fixtures :taxa, :projects, :iczn_groups, :import_jobs
  # test "the truth" do
  #   assert true
  # end

  test "Child taxa are in same project as parent" do
    import_job = import_jobs(:import_job1)
    parent = taxa(:homo)
    child = Taxon.find_or_create_with_parent("child", parent, iczn_groups(:species), import_job)
    assert_equal(child.project, import_job.project)
  end
end
