require 'json'
module Pec
  class Network
    class Port
      extend Query
      class << self
        @@use_ip_list = []

        def assign(ether, host_options)
          begin
            ip = IP.new(ether.ip_address)
            ip = get_free_port_ip(ip) if request_any_address?(ip)
          rescue ArgumentError => e
            raise(Pec::Errors::Port, "ip:#{ether.ip_address} #{e}")
          end

          port_state = Pec::Network::PortState.new(ether.name, fetch_by_ip(ip.to_addr))
          attribute = port_options(ip, ether, host_options)
          assign_port = case
            when port_state.exists? &&  !port_state.used?
              create(ip, attribute) if delete(ip)
            when !port_state.exists?
              create(ip, attribute)
            when port_state.used?
              raise(Pec::Errors::Port, "ip:#{ip.to_addr} is used!")
          end
          Pec::Network::PortState.new(ether.name, assign_port)
        end

        def create(ip, attribute)
          response = Pec::Resource.get.create_port(subnet(ip)["network_id"], attribute)
          raise(Pec::Errors::Port, "ip:#{ip.to_addr} is not created!") unless response[:status] == 201
          append_assigned_ip(response)
          parse_response(response)
        end

        def delete(ip)
          target_port = fetch_by_ip(ip.to_addr)
          response = Pec::Resource.get.delete_port(target_port["id"]) if target_port
          raise(Pec::Errors::Host, "ip:#{ip.to_addr} response err status:#{response[:status]}") unless response[:status] == 204
          true
        end

        def subnet(ip)
          unless port_subnet = Pec::Network::Subnet.fetch_by_cidr(ip.network.to_s)
            raise(Pec::Errors::Subnet, "subnet:#{ip.network.to_s} is not fond!")
          end
          port_subnet
        end
       
        def port_options(ip, ether, host_options)
          attribute = {}
          attribute.merge!(security_group(host_options['security_group'])) if host_options && host_options['security_group']
          attribute.merge!(fixed_ip_hash(ip)) if ip && fixed_ip_hash(ip)
          attribute.merge!(allowed_address_pairs(ether)) if ether.allowed_address_pairs
          attribute
        end

        def security_group(security_groups)
          ids = security_groups.map do |sg_name|
            sg = Pec::Network::Security_Group.fetch(sg_name)
            raise(Pec::Errors::SecurityGroup, "security_group:#{sg_name} is not found!") unless sg
            sg["id"]
          end if security_groups
          { security_groups:  ids }
        end

        def allowed_address_pairs(ether)
          { allowed_address_pairs: ether.allowed_address_pairs }
        end

        def fixed_ip_hash(ip)
          { fixed_ips: [{ subnet_id: subnet(ip)["id"], ip_address: ip.to_addr }] } unless ip.to_s == subnet(ip)["cidr"] 
        end

        def append_assigned_ip(response)
          @@use_ip_list << fixed_ip_by_port(parse_response(response))
        end

        def assigned_ip?(port)
          @@use_ip_list.include?(fixed_ip_by_port(port))
        end

        def get_free_port_ip(ip)
          port = list.find do |p|
            same_subnet?(p, ip) &&
            unused?(p) &&
            admin_state_up?(p) &&
            !assigned_ip?(p)
          end
          port ? IP.new("#{fixed_ip_by_port(port)}/#{ip.pfxlen}") : ip
        end

        def fetch_by_ip(ip_addr)
          list.find {|p| fixed_ip_by_port(p) == ip_addr }
        end

        def parse_response(response)
          response.data[:body]["port"]
        end

        def fixed_ip_by_port(port)
          port["fixed_ips"][0]["ip_address"] 
        end

        def request_any_address?(ip)
          ip.to_s == subnet(ip)["cidr"]
        end

        def same_subnet?(port, ip)
          port["fixed_ips"][0]["subnet_id"] == subnet(ip)["id"]
        end

        def unused?(port)
          port["device_owner"].empty?
        end

        def admin_state_up?(port)
          port["admin_state_up"]
        end
      end
    end
  end
end
