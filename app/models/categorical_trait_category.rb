class CategoricalTraitCategory < ActiveRecord::Base
  attr_accessible :name
  has_many :categorical_trait_values
  belongs_to :categorical_trait
end
