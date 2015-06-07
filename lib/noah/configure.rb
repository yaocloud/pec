require 'yaml'
module Noah
  class Configure
    include Enumerable

    def load(file_name)
      YAML.load_file(file_name).to_hash.each do |config|
        host = Noah::Configure::Host.load(config)
        @configure ||= []
        @configure << host if host
      end
      rescue Psych::SyntaxError => e
        puts e
    end

    def each
      @configure.each do |config|
        yield config
      end
    end
  end
end
