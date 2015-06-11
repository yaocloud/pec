module Pec
  class VmDirector
    def initialize
        @subnet = Pec::Network::Subnet.new
        @flavor = Pec::Compute::Flavor.new
        @image = Pec::Compute::Image.new
        @security_group = Pec::Compute::Security_Group.new
        @compute = Pec::Compute::Server.new
    end

    def make(config)
      if @compute.exists?(config.name)
        puts "skip create server! name:#{config.name} is exists!"
        return true
      end

      ports = get_ports(config)
      flavor_ref = @flavor.get_ref(config.flavor)
      image_ref = @image.get_ref(config.image)
      options = { "user_data" => Pec::Configure::UserData.make(config, ports) }

      @compute.create(config.name, image_ref, flavor_ref, ports, options)
    end

    def destroy!(server_name)
      @compute.destroy!(host.name)
    end

    def get_ports(config)
      config.networks.map do |ether|
        begin
          ip = IP.new(ether.ip_address)
        rescue ArgumentError => e
          raise(Pec::Errors::Port, "ip:#{ether.ip_address} #{e}")
        end

        subnet = @subnet.fetch(ip.network.to_s)
        raise(Pec::Errors::Subnet, "subnet:#{ip.network.to_s} is not fond!") unless subnet

        port = Pec::Network::Port.new(ether.name, ip.to_addr, subnet, get_security_group_id(config.security_group))
        raise(Pec::Errors::Port, "ip addess:#{ip.to_addr} can't create port!") unless port.assign!(ip)
        port
      end if config.networks
    end

    def get_security_group_id(security_groups)
      security_groups.map do |name|
        sg = @security_group.fetch(name)
        raise(Pec::Errors::SecurityGroup, "security_group:#{name} is not found!") unless sg
        sg["id"]
      end if security_groups
    end
  end
end
