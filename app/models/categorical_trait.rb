class CategoricalTrait < ActiveRecord::Base
  include TraitCommon
  has_many :categorical_trait_categories, :dependent => :destroy
  has_many :otus, :through => :categorical_trait_categories, :source => :categorical_trait_values
  has_many :categorical_trait_notes

  def category_names
    categorical_trait_categories.pluck(:name)
  end

  def summarization_method
    :collect
  end
end
