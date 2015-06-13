module Pec
  class Director
    class Helper
      class << self

        def ports_assign(host, subnet, security_group)
          host.networks.map do |ether|
            begin
              ip = IP.new(ether.ip_address)
            rescue ArgumentError => e
              raise(Pec::Errors::Port, "ip:#{ether.ip_address} #{e}")
            end

            port_subnet = subnet.fetch(ip.network.to_s)
            raise(Pec::Errors::Subnet, "subnet:#{ip.network.to_s} is not fond!") unless port_subnet

            port = Pec::Network::Port.new.assign(ether.name, ip, port_subnet, get_security_group_id(host.security_group, security_group))
            raise(Pec::Errors::Port, "ip addess:#{ip.to_addr} can't create port!") unless port

            puts "#{host.name}: assingn ip #{port.ip_address}"
            port
          end if host.networks
        end

        def get_nics(ports)
          { 'nics' =>  ports.map { |port| { port_id: port.id } }}
        end

        def get_security_group_id(security_groups, security_group)
          security_groups.map do |sg_name|
            sg = security_group.fetch(sg_name)
            raise(Pec::Errors::SecurityGroup, "security_group:#{sg_name} is not found!") unless sg
            sg["id"]
          end if security_groups
        end
      end
    end
  end
end
