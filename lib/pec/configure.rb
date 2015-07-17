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

      hash.each do |config|
        next if config[0] =~ /^_.+_$/

        config[1]['user_data'] ||= {}
        config[1]['user_data']['fqdn'] ||= config[0]

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
