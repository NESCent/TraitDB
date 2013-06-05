class CategoricalTraitNote < ActiveRecord::Base
  attr_accessible :categorical_trait_id, :notes, :otu_id
  belongs_to :otu
  belongs_to :categorical_trait
end
