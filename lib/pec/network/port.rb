require 'json'
module Pec
  class Network
    class Port
      extend Query
      class << self
        @@use_ip_list = []

        def assign(name, ip, security_group_ids)
          ip = get_free_port_ip(ip) if request_any_address?(ip)
          port_state = Pec::Network::PortState.new(name, fetch_by_ip(ip.to_addr))
          assign_port = case
            when port_state.exists? &&  !port_state.used?
              create(ip, security_group_ids) if delete(ip)
            when !port_state.exists?
              create(ip, security_group_ids)
            when port_state.used?
              raise(Pec::Errors::Port, "ip:#{ip.to_addr} is used!")
          end
          Pec::Network::PortState.new(name, assign_port)
        end

        def create(ip, security_groups)
          options  = security_group_ids(security_groups)
          options  = set_fixed_ip(options, ip)
          response = Pec::Resource.get.create_port(subnet(ip)["network_id"], options)
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
        
        def security_group_ids(security_groups)
          ids = security_groups.map do |sg_name|
            sg = Pec::Network::Security_Group.fetch(sg_name)
            raise(Pec::Errors::SecurityGroup, "security_group:#{sg_name} is not found!") unless sg
            sg["id"]
          end if security_groups
          { security_groups:  ids }
        end

        def set_fixed_ip(options, ip)
          ip.to_s != subnet(ip)["cidr"] ? options.merge({ fixed_ips: [{ subnet_id: subnet(ip)["id"], ip_address: ip.to_addr}]}) : options
        end

        def append_assigned_ip(response)
          @@use_ip_list << fixed_ip(parse_response(response))
        end

        def assigned_ip?(port)
          @@use_ip_list.include?(fixed_ip(port))
        end

        def get_free_port_ip(ip)
          port = list.find do |p|
            same_subnet?(p, ip) &&
            unused?(p) &&
            admin_state_up?(p) &&
            !assigned_ip?(p)
          end
          port ? IP.new("#{fixed_ip(port)}/#{ip.pfxlen}") : ip
        end

        def fetch_by_ip(ip_addr)
          list.find {|p| fixed_ip(p) == ip_addr }
        end

        def parse_response(response)
          response.data[:body]["port"]
        end

        def fixed_ip(port)
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
