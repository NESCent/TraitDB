class TraitGroup < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :continuous_traits
  has_and_belongs_to_many :categorical_traits
  has_and_belongs_to_many :taxa
end
