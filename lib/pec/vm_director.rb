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
      flavor_ref = get_flavor(config.flavor)
      image_ref = get_image(config.image)

      return false unless flavor_ref && image_ref

      options = {
        "user_data" => Pec::Configure::UserData.make(config, ports),
      }
      @compute.create(config.name, image_ref, flavor_ref, ports, options)
    end

    def get_ports(config)
      config.networks.map do |ether|
        ip = IP.new(ether.ip_address)
        _subnet = get_subnet(ip)
        _port = Pec::Network::Port.new(ether.name, ip.to_addr, _subnet, get_security_group_id(config.security_group)) if _subnet

        unless _port.assign!(ip)
          puts "ip addess:#{ip.to_addr} can't create port!"
          return false
        end
        _port
      end if config.networks
    end

    def get_subnet(ip)
      _subnet = @subnet.fetch(ip.network.to_s)
      puts "ip addess:#{ip.to_addr} subnet not fond!" if _subnet.nil?
      _subnet
    end

    def get_flavor(name)
      flavor_ref = @flavor.get_ref(name)
      puts "flavor:#{name} not fond!" if flavor_ref.nil?
      flavor_ref
    end

    def get_image(name)
      image_ref = @image.get_ref(name)
      puts "image:#{name} not fond!" if image_ref.nil?
      image_ref
    end

    def get_security_group_id(security_groups)
      security_groups.map do |name|
        sg = @security_group.fetch(name)
        sg["id"] if sg
      end if security_groups
    end
  end
end
