module Pec
  class Configure
    def initialize(config)
      @_config = config
    end

    def name
      @_config[0]
    end

    def method_missing(method, *args)
      nil unless @_config[1][method.to_s]
      @_config[1][method.to_s]
    end
  end
end
