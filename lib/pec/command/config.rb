module Pec::Command
  class Config < Base
    def self.task(host_name, options, server, config)
      puts YAML.dump(config.inspect[0] => config.inspect[1])
    end
  end
end
