module Pec::Handler
  class Flavor
    extend Pec::Core
    self.kind = 'image'

    def self.build(config)
      Pec::Logger.notice "flavor is #{config.flavor}"
      flavor_id = Yao::Flavor.list.find {|flavor| flavor.name == config.flavor}.id
      {
        flavorRef:  flavor_id
      }
    rescue
      raise Pec::ConfigError, "flavor name=#{config.flavor} does not exist"
    end
  end
end
