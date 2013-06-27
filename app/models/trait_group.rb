class TraitGroup < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :continuous_traits
  has_and_belongs_to_many :categorical_traits
  has_and_belongs_to_many :taxa
  scope :by_taxon, lambda{|taxon| taxon.trait_groups}
  scope :sorted, order('name ASC')
end
