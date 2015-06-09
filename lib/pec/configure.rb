require 'yaml'
module Pec
  class Configure
    include Enumerable

    def load(file_name)
      YAML.load_file(file_name).to_hash.each do |config|
        host = Pec::Configure::Host.load(config)
        @configure ||= []
        @configure << host if host
      end
      rescue Psych::SyntaxError,NoMethodError => e
        raise(Pec::Errors::Configure, e)
    end

    def each
      @configure.each do |config|
        yield config
      end
    end
  end
end
