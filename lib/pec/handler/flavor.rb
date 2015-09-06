module Pec::Handler
  class Flavor < Base 
    self.kind = 'image'

    def self.build(host)
      Pec::Logger.notice "flavor is #{host.flavor}"
      {
        flavorRef:  Yao::Flavor.list.find {|flavor| flavor.name == host.flavor}.id
      }
    end
  end
end
