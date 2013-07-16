class TraitSet < ActiveRecord::Base
  belongs_to :parent_trait_set, :class_name => 'TraitSet'
  has_many :trait_sets, :foreign_key => :parent_trait_set_id
  has_many :categorical_traits
  has_many :continuous_traits
  attr_accessible :level, :name

  # given a path (an array of strings), look for nested trait sets with the provided names
  # Create any missing nodes and return the tip
  def self.find_or_create_with_path(path)
    last_set = nil
    path.each do |pathname|
      h = {:name => pathname}
      h[:parent_trait_set_id] = last_set.id if last_set
      last_set = TraitSet.where(h).first_or_create
    end
    last_set
  end
end
