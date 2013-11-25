class TraitSet < ActiveRecord::Base
  belongs_to :project
  belongs_to :parent_trait_set, :class_name => 'TraitSet'
  has_many :trait_sets, :foreign_key => :parent_trait_set_id
  has_many :categorical_traits
  has_many :continuous_traits
  attr_accessible :level, :name
  scope :by_project, lambda{|p| where(:project_id => p) unless p.nil?}
  scope :by_level, lambda{|l| where(:level => l) unless l.nil?}
  scope :sorted, -> { order('name ASC') }
  scope :roots, -> { where(:parent_trait_set_id =>  nil) }

  # works on a relation/scope
  def self.levels
    order('level').pluck(:level).uniq
  end

  # given a path (an array of strings), look for nested trait sets with the provided names
  # Create any missing nodes and return the tip
  def self.find_or_create_with_path(containing_project, path)
    last_set = nil
    path.each_with_index do |pathname, i|
      h = {:name => pathname}
      h[:parent_trait_set_id] = last_set.id if last_set
      last_set = containing_project.trait_sets.where(h).first_or_create do |s|
        s.level = i
      end
    end
    last_set
  end

  def full_name
    if parent_trait_set
      return "#{parent_trait_set.full_name}: #{name}"
    else
      return name
    end
  end
end
