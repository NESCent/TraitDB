class DisplayFormat < ActiveRecord::Base
  attr_accessible :name
  has_many :categorical_traits
  has_many :continuous_traits
  def format_value(value)
    case name
      when 'integer'
        value = Integer(value)
      when 'float'
        value = Float(value)
      when 'string'
        value = String(value)
      end
    value
  end
end
