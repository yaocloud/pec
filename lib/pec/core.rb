module Pec::Core
  attr_accessor :kind
  def build
    raise "#{self.class.name} not defined method build"
  end
end
