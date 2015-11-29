module Pec::Command
  class Config < Base
    def self.task(options, server, config)
      puts YAML.dump(config.inspect[0] => config.inspect[1])
    end

    def self.not_fetch
      true
    end
  end
end
