class ContinuousTrait < ActiveRecord::Base
  include TraitCommon
  has_many :continuous_trait_values
  has_many :otus, :through => :continuous_trait_values
  has_many :continuous_trait_notes

  def display_format_name
    if display_format
      display_format.name
    else
      'Default'
    end
  end
end
