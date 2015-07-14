module Pec
  class Director
    class Helper
      class << self

        def ports_assign(host)
          host.networks.map do |ether|
            ip = IP.new(ether.ip_address)

            unless port_subnet = Pec::Network::Subnet.fetch_by_cidr(ip.network.to_s)
              raise(Pec::Errors::Subnet, "subnet:#{ip.network.to_s} is not fond!")
            end

            unless port = Pec::Network::Port.assign(ether.name, ip, port_subnet, get_security_group_id(host.security_group))
              raise(Pec::Errors::Port, "ip addess:#{ip.to_addr} can't create port!")
            end

            puts "#{host.name}: assingn ip #{port.ip_address}".green
            port
          end if host.networks
          rescue ArgumentError => e
            raise(Pec::Errors::Port, "ip:#{ether.ip_address} #{e}")
        end

        def set_nics(options, ports)
          ports ? options.merge({ 'nics' =>  ports.map { |port| { port_id: port.id } } }) : options
        end

        def get_security_group_id(security_groups)
          security_groups.map do |sg_name|
            sg = Pec::Network::Security_Group.fetch(sg_name)
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
