require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  # Test that project has a name after creation
  test "Project exists" do
    assert_not_nil Project.first
    assert_not_nil Project.last
  end

  test "Project has name" do
    Project.all.each do |project|
      assert_not_nil project.name
    end
  end

  # how to test for validates_uniqueness_of ?

  test "Project add iczn groups uniquely" do
    p = Project.first
    assert_empty p.iczn_groups
    p.add_iczn_groups(IcznGroup.all)
    p.add_iczn_groups(IcznGroup.all)
    assert_equal p.iczn_groups, IcznGroup.all
  end
end
