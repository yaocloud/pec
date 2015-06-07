module Noah
  class VmDirector
    def initialize
        @subnet = Noah::Network::Subnet.new
        @flavor = Noah::Compute::Flavor.new
        @image = Noah::Compute::Image.new
        @security_group = Noah::Compute::Security_Group.new
        @compute = Noah::Compute::Server.new
    end

    def make(config)
      ports = get_ports(config)
      flavor_ref = get_flavor(config.flavor)
      image_ref = get_image(config.image)
      return false unless flavor_ref && image_ref
      options = {
        "user_data" => Noah::Configure::UserData.make(config, ports),
        "security_groups" => config.security_group
      }

      @compute.create(config.name, image_ref, flavor_ref, ports, options)
    end

    def get_ports(config)
      config.networks.map do |ether|
        ip = IP.new(ether.ip_address)
        _subnet = get_subnet(ip)
        return false unless _subnet

        _port = Noah::Network::Port.new(ether.name, ip.to_addr, _subnet)

        res = case
        when _port.exists? && !_port.used?
          _port.replace(ip)
        when !_port.exists?
          _port.create(ip)
        when _port.used?
          false
        end

        unless res
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
  end
end
