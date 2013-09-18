class ContinuousTraitNote < ActiveRecord::Base
  attr_accessible :continuous_trait_id, :notes, :otu_id
  belongs_to :otu
  belongs_to :continuous_trait
  scope :by_otu, lambda{|o| where(:otu_id => o) unless o.nil?}
  scope :by_continuous_trait, lambda{|t| where(:continuous_trait_id => t) unless t.nil?}
end
