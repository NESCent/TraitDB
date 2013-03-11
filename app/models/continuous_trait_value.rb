class ContinuousTraitValue < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :otu
  belongs_to :continuous_trait

end
