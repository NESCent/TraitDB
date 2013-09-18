class CategoricalTraitNote < ActiveRecord::Base
  attr_accessible :categorical_trait_id, :notes, :otu_id
  belongs_to :otu
  belongs_to :categorical_trait
  scope :by_otu, lambda{|o| where(:otu_id => o) unless o.nil?}
  scope :by_categorical_trait, lambda{|t| where(:categorical_trait_id => t) unless t.nil?}
  en
end
