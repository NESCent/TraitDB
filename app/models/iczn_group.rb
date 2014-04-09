SEED_ICZN_GROUPS = [
  {name: 'kingdom',        level: 100},
  {name: 'htg',            level: 200},
  {name: 'order',          level: 300},
  {name: 'family',         level: 400},
  {name: 'subfamily',      level: 450},
  {name: 'genus',          level: 500},
  {name: 'species',        level: 600},
  {name: 'population',     level: 650},
  {name: 'species_author', level: 700},
  {name: 'infraspecific',  level: 800}
]

class IcznGroup < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name, :level
  has_many :taxa, :dependent => :nullify
  has_and_belongs_to_many :projects
  scope :sorted, -> { order('level ASC') }
  scope :by_level, lambda{|level| where(:level => level)}
  scope :by_name, lambda{|name| where(:name => name)}

  # returns negative if other group is more specific than self
  def distance(other_group)
    IcznGroup.sorted.index(self) - IcznGroup.sorted.index(other_group)
  end

end
