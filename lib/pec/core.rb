module Pec
  module Core
    attr_accessor :kind
    def build(*args)
      raise "#{self.class.name} not defined method build"
    end

    def post_build(*args); end

    def recover(*args); end
  end
end
