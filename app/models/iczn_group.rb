class IcznGroup < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name, :level
  has_many :taxa, :dependent => :nullify
  scope :sorted, order('level ASC') # kingdom ... species
end
