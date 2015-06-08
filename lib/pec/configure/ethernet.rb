module Pec
  class Configure
    class Ethernet
      attr_reader :name, :bootproto, :ip_address, :options
      def initialize(config)
        @name = config[0];
        @bootproto = config[1]["bootproto"];
        @ip_address = config[1]["ip_address"];
        @options = config[1].select do |k,v|
          { k => v } if k != "bootproto" && k != "ip_address"
        end
      end

      class << self
        def load(name, config)
          self.new(config) if check_require_key(name, config) && check_network_key(name, config)
        end

        def check_require_key(name, config)
          err = %w(bootproto).find {|k| !config[1].key?(k)}
          return true if err.nil?
          puts "skip! #{name}: #{err} is required!"
          false
        end

        def check_network_key(name, config)
          net = config[1]
          case
          when (net["bootproto"] == "static" && net["ip_address"].nil?)
            puts "skip! #{name}: ip_address is required by bootproto static"
            return false
          when (!net["bootproto"] == "static" && !net["bootproto"] == "dhcp")
            puts "skip! #{name}: bootproto set the value dhcp or static"
            return false
          when (!net["bootproto"] == "static" && !net["bootproto"] == "dhcp")
            puts "skip! #{name}: bootproto set the value dhcp or static"
            return false
          end
          true
        end
      end
    end
  end
end
