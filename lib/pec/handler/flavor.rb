module Pec::Handler
  class Flavor < Base 
    self.kind = 'image'

    def self.build(host)
      Pec::Logger.notice "flavor is #{host.flavor}"
      {
        flavor_ref: fetch_flavor(host).id,
      }
    end
  end
end
