class TraitSet < ActiveRecord::Base
  belongs_to :parent_trait_set, :class_name => 'TraitSet'
  has_many :trait_sets, :foreign_key => :parent_trait_set_id
  has_many :categorical_traits
  has_many :continuous_traits
  attr_accessible :level, :name
end
