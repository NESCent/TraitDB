class IcznGroup < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name, :level
  has_many :taxa, :dependent => :nullify
  scope :sorted, order('level ASC') # kingdom ... species

  # returns negative if other group is more specific than self
  def distance(other_group)
    IcznGroup.sorted.index(self) - IcznGroup.sorted.index(other_group)
  end
end
