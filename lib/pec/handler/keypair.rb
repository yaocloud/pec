module Pec::Handler
  class Keypair
    extend Pec::Core
    self.kind = 'keypair'

    def self.build(config)
      return({}) unless config.keypair

      Pec::Logger.notice "keypair is #{config.keypair}"
      keypair = Yao::Keypair.list.find {|k| k.name == config.keypair }
      if keypair
        {
          key_name: keypair.name,
        }
      else
        raise Pec::ConfigError, "keypair name=#{config.keypair} does not exist"
      end
    end
  end
end
