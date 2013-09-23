class SourceReference < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :project
  has_many :continuous_trait_values
  has_many :categorical_trait_values
  scope :by_project, lambda{|p| where(:project_id => p) unless p.nil?}
  attr_accessible :source

end
