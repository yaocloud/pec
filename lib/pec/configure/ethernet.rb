module Pec
  class Configure
    class Ethernet
      attr_reader :name, :bootproto, :ip_address, :options
      def initialize(config)
        @name       = config[0];
        @bootproto  = config[1]["bootproto"];
        @ip_address = config[1]["ip_address"];
        @options    = config[1].select do |k,v|
          { k => v } if k != "bootproto" && k != "ip_address"
        end
      end

      def find_port(ports)
        ports.find { |p| p.device_name == @name }
      end

      class << self
        def load(name, config)
          self.new(config) if check_require_key(name, config) && check_network_key(name, config)
        end

        def check_require_key(name, config)
          raise(Pec::Errors::Ethernet, "skip! #{name}: bootproto is required!") if config[1]["bootproto"].nil?
          true
        end

        def check_network_key(name, config)
          net = config[1]
          case
          when (net["bootproto"] == "static" && net["ip_address"].nil?)
            raise(Pec::Errors::Ethernet, "skip! #{name}: ip_address is required by bootproto static")
          when (net["bootproto"] != "static" && net["bootproto"] != "dhcp")
            raise(Pec::Errors::Ethernet, "skip! #{name}: bootproto set the value dhcp or static")
          end
          true
        end
      end
    end
  end
end
