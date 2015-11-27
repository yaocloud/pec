module Pec
  module Core
    attr_accessor :kind, :recover_kind
    def build(*args)
      raise "#{self.class.name} not defined method build"
    end

    def recover(*args); end
  end
end
