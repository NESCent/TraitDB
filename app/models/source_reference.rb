class SourceReference < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :continuous_trait_values
  has_many :categorical_trait_values
  attr_accessible :last_name, :first_name, :year, :title, :url

  def to_s
    title
  end

end
