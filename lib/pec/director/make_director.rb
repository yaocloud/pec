module Pec
  class Director
    class MakeDirector
      def initialize(options)
          @subnet = Pec::Network::Subnet.new
          @flavor = Pec::Compute::Flavor.new
          @image = Pec::Compute::Image.new
          @security_group = Pec::Compute::Security_Group.new
          @compute = Pec::Compute::Server.new
          @options = options
      end

      def execute!(host)
        make(host)
      end

      def do_it?(host)
        true
      end

      def make(host)
        if @compute.exists?(host.name)
          puts "skip create server! name:#{host.name} is exists!"
          return true
        end

        ports = get_ports(host)
        flavor_ref = @flavor.get_ref(host.flavor)
        image_ref = @image.get_ref(host.image)
        options = { "user_data" => Pec::Configure::UserData.make(host, ports) }

        @compute.create(host.name, image_ref, flavor_ref, ports, options)
      end

      def get_ports(host)
        host.networks.map do |ether|
          begin
            ip = IP.new(ether.ip_address)
          rescue ArgumentError => e
            raise(Pec::Errors::Port, "ip:#{ether.ip_address} #{e}")
          end

          subnet = @subnet.fetch(ip.network.to_s)
          raise(Pec::Errors::Subnet, "subnet:#{ip.network.to_s} is not fond!") unless subnet

          port = Pec::Network::Port.new(ether.name, ip.to_addr, subnet, get_security_group_id(host.security_group))
          raise(Pec::Errors::Port, "ip addess:#{ip.to_addr} can't create port!") unless port.assign!(ip)
          port
        end if host.networks
      end

      def get_security_group_id(security_groups)
        security_groups.map do |name|
          sg = @security_group.fetch(name)
          raise(Pec::Errors::SecurityGroup, "security_group:#{name} is not found!") unless sg
          sg["id"]
        end if security_groups
      end

      def err_message(e, host)
          puts e
          puts "can't create server:#{host.name}"
      end
    end
  end
end
