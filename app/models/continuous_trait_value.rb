class ContinuousTraitValue < ActiveRecord::Base
  attr_accessible :continuous_trait_id, :value, :source_reference_id
  belongs_to :otu
  belongs_to :continuous_trait
  belongs_to :source_reference
  scope :sorted, order('value ASC')
end
