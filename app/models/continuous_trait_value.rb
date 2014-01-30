class ContinuousTraitValue < ActiveRecord::Base
  attr_accessible :position, :continuous_trait_id, :value, :source_reference_id, :otu_id
  belongs_to :otu
  belongs_to :continuous_trait
  belongs_to :source_reference
  scope :sorted, -> { order('position ASC') }
  def formatted_value
    return value unless continuous_trait.display_format_id
    self.continuous_trait.display_format.format_value(value)
  end
end
