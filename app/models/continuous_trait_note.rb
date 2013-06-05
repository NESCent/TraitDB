class ContinuousTraitNote < ActiveRecord::Base
  attr_accessible :continuous_trait_id, :notes, :otu_id
  belongs_to :otu
  belongs_to :continuous_trait
end
