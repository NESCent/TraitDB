class CategoricalTraitValue < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :otu
  belongs_to :categorical_trait_category
  has_one :categorical_trait, :through => :categorical_trait_category
end
