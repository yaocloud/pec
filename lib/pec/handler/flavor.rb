module Pec::Handler
  class Flavor
    extend Pec::Core
    self.kind = 'image'

    def self.build(host)
      Pec::Logger.notice "flavor is #{host.flavor}"
      flavor_id = Yao::Flavor.list.find {|flavor| flavor.name == host.flavor}.id
      {
        flavorRef:  flavor_id
      }
    rescue
      raise Pec::ConfigError, "flavor name=#{host.flavor} does not exist"
    end
  end
end
