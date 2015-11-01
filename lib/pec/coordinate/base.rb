module Pec::Coordinate
  class Base
    class << self
      attr_accessor :kind
      def build(attribute)
        raise "not defined method"
      end
    end
  end
end
