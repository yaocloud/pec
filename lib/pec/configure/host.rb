module Pec
  class Configure
    class Host
      attr_reader :name, :image, :flavor,:security_group, :user_data, :networks, :templates, :tenant, :availability_zone
      def initialize(config)
        check_format(config)
        set_network(config[1])
        @name              = config[0];
        %w(
          image
          flavor
          security_group
          user_data
          templates
          tenant
          availability_zone
        ).each do |c|
          instance_variable_set('@'+c, config[1][c])
        end
      end

      def set_network(config)
        @networks ||= []
        config["networks"].each do |net|
          raise(Pec::Errors::Ethernet, "please! network interface format is Array") unless net.kind_of?(Array)

          if ethernet = Pec::Configure::Ethernet.new(config, net)
            @networks << ethernet
          end

        end if config["networks"]
      end

      def check_format(config)
        err = %w(image flavor tenant).find {|r| !config[1].key?(r) || config[1][r].nil? }
        raise(Pec::Errors::Host,"skip! #{config[0]}: #{err} is required!") unless  err.nil?
        true
      end

      def ports
        @_ports ||= self.networks.map do |ether|
          unless port = Pec::Network::Port.assign(ether, port_options)
            raise(Pec::Errors::Port, "ip addess:#{ether.ip_address} can't create port!")
          end
          puts "#{self.name}: assingn ip #{port.ip_address}".green
          port
        end if self.networks
        @_ports
      end

      def port_options
        %w(
          security_group
        ).reduce({}) do |hash,name|
          hash[name] = self.send(name)
          hash
        end
      end
    end
  end
end
