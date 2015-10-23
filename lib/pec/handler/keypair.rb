module Pec::Handler
  class Keypair < Base
    self.kind = 'keypair'

    def self.build(host)
      return({}) unless host.keypair

      Pec::Logger.notice "keypair is #{host.keypair}"
      keypair = Yao::Keypair.list.find {|k| k.name == host.keypair }
      if keypair
        {
          key_name: keypair.name,
        }
      else
        raise Pec::ConfigError, "keypair name=#{host.keypair} does not exist"
      end
    end
  end
end
