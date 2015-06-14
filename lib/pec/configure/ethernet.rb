module Pec
  class Configure
    class Ethernet
      attr_reader :name, :bootproto, :ip_address, :options
      def initialize(config)
        @name       = config[0];
        @bootproto  = config[1]["bootproto"];
        @ip_address = config[1]["ip_address"];
        @options    = config[1].reject do |k,v|
          { k => v } if k == "bootproto" && k == "ip_address"
        end
      end

      def get_port_content(ports)
        base = {
          "bootproto" => @bootproto,
          "name"      => config_name,
          "device"    => device_name,
          "type"      => type,
          "onboot"    => onboot,
          "hwaddr"    => mac_address(ports),
        }
        base.merge!({ "netmask" => netmask(ports), "ipaddr" => port_ip_address(ports) }) if static?
        base.merge!(@options) if @options
        base.map {|k,v| "#{k.upcase}=#{v}"}.join("\n")
      end


      def config_name
        @options["name"] || @name
      end

      def device_name
        @options["device"] || @name
      end

      def type
        @options["type"] || 'Ethernet'
      end

      def onboot
        @options["onboot"] || 'yes'
      end

      def mac_address(ports)
         ports.find { |p| p.device_name == @name }.mac_address
      end

      def netmask(ports)
        ports.find { |p| p.device_name == @name }.netmask
      end

      def port_ip_address(ports)
        ports.find { |p| p.device_name == @name }.ip_address
      end

      def static?
        @bootproto == "static"
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
