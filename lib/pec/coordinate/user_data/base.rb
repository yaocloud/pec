module Pec::Coordinate
  class UserData::Base
    class << self
      attr_accessor :kind
      def build
        raise "undefine method build"
      end
    end
  end
end
