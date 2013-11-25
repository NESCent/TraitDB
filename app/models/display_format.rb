class DisplayFormat < ActiveRecord::Base
  attr_accessible :name
  has_many :categorical_traits, :dependent => :nullify
  has_many :continuous_traits, :dependent => :nullify
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
