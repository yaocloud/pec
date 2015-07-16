require 'yaml'
module Pec
  class Configure
    include Enumerable

    def initialize(file_name)
      @configure = []

      if file_name.is_a?(Hash)
        hash = file_name
      else
        hash = YAML.load_file(file_name).to_hash
      end

      config_default = {}
      hash.each do |config|
        if config[0] =~ /^_DEFAULT_/
          config_default = config_default.update(config[1])
          next
        end
        config[1] = config_default.update(config[1])

        host = Pec::Configure::Host.new(config)
        @configure << host if host
      end
      rescue Psych::SyntaxError,NoMethodError => e
        raise(Pec::Errors::Configure, e)
    end

    def filter_by_host(host_name)
      @configure.select {|h| host_name.nil? || host_name == h.name}
    end

    def each
      @configure.each do |config|
        yield config
      end
    end
  end
end
