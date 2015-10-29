require "pec/config_error"

module Pec
  class Configure
    def initialize(config)
      validate(config)
      @_config = config
    end

    def inspect
      @_config
    end

    def name
      @_config[0]
    end

    def keys
      @_config[1].keys
    end

    def method_missing(method, *args)
      @_config[1][method.to_s]
    end

    def validate(host)
      %w(
        tenant
        image
        flavor
        networks
      ).each do |k|
        raise "host key #{k} is require" unless host[1][k]
      end
    end
  end
end
