class IcznGroup < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name
  has_many :taxa
end
