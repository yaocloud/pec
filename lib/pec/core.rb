module Pec
  module Core
  attr_accessor :kind
  def build(*args)
    raise "#{self.class.name} not defined method build"
  end
end
