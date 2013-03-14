class ContinuousTraitValue < ActiveRecord::Base
  attr_accessible :continuous_trait_id, :value
  belongs_to :otu
  belongs_to :continuous_trait

  scope :sorted, order('value ASC')

end
