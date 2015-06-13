module Pec
  class Director
    class Helper
      class << self

        def ports_assign(host)
          host.networks.map do |ether|
            begin
              ip = IP.new(ether.ip_address)
            rescue ArgumentError => e
              raise(Pec::Errors::Port, "ip:#{ether.ip_address} #{e}")
            end

            port_subnet = Pec::Network::Subnet.fetch(ip.network.to_s)
            raise(Pec::Errors::Subnet, "subnet:#{ip.network.to_s} is not fond!") unless port_subnet

            port = Pec::Network::Port.new.assign(ether.name, ip, port_subnet, get_security_group_id(host.security_group))
            raise(Pec::Errors::Port, "ip addess:#{ip.to_addr} can't create port!") unless port

            puts "#{host.name}: assingn ip #{port.ip_address}"
            port
          end if host.networks
        end

        def get_nics(ports)
          { 'nics' =>  ports.map { |port| { port_id: port.id } }}
        end

        def get_security_group_id(security_groups)
          security_groups.map do |sg_name|
            sg = Pec::Compute::Security_Group.fetch(sg_name)
            raise(Pec::Errors::SecurityGroup, "security_group:#{sg_name} is not found!") unless sg
            sg["id"]
          end if security_groups
        end

        def parse_from_addresses(addresses)
          addresses.map do |net, ethers|
            ethers.map do |ether|
              ether["addr"]
            end
          end.flatten
        end
      end
    end
  end
end
