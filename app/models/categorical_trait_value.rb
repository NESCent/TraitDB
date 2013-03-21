class CategoricalTraitValue < ActiveRecord::Base
  attr_accessible :position, :categorical_trait_category_id, :categorical_trait_id, :source_reference_id
  belongs_to :otu
  belongs_to :categorical_trait_category
  has_one :categorical_trait, :through => :categorical_trait_category
  belongs_to :source_reference
  scope :sorted, order('position ASC')

end
