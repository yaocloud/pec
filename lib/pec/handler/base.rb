module Pec::Handler
  class Base
    class << self
      attr_accessor :kind
      def build
        raise "not defined method"
      end
    end
  end
end
