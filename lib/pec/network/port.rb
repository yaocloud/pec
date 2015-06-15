require 'json'
module Pec
  class Network
    class Port
      extend Query
      class << self
        @@use_ip_list = []

        def assign(name, ip, subnet, security_group_ids)
          ip = get_free_port_ip(ip, subnet) if request_any_address?(ip, subnet)
          port_state = Pec::Network::PortState.new(name, fetch_by_ip(ip.to_addr))

          assign_port = case
            when port_state.exists? &&  !port_state.used?
              recreate(ip, subnet, security_group_ids)
            when !port_state.exists?
              create(ip, subnet, security_group_ids)
            when port_state.used?
              raise(Pec::Errors::Port, "ip:#{ip.to_addr} is used!")
          end
          Pec::Network::PortState.new(name, assign_port)
        end

        def create(ip, subnet, security_group_ids)
          options  = set_security_group(security_group_ids)
          options  = set_fixed_ip(options, subnet, ip)
          response = Pec::Resource.get.create_port(subnet["network_id"], options)
          raise(Pec::Errors::Port, "ip:#{ip.to_addr} is not created!") unless response[:status] == 201
          append_assigned_ip(response)
          port_from_response(response)
        end

        def delete(ip)
          target_port = fetch_by_ip(ip.to_addr)
          response = Pec::Resource.get.delete_port(target_port["id"]) if target_port
          raise(Pec::Errors::Host, "ip:#{ip.to_addr} response err status:#{response[:status]}") unless response[:status] == 204
          true
        end

        def recreate(ip, subnet, security_group_ids)
          create(ip, subnet, security_group_ids) if delete(ip)
        end

        def set_security_group(security_group_ids)
          { security_groups: security_group_ids }
        end

        def set_fixed_ip(options, subnet, ip)
          ip.to_s != subnet["cidr"] ? options.merge({ fixed_ips: [{ subnet_id: subnet["id"], ip_address: ip.to_addr}]}) : options
        end

        def append_assigned_ip(response)
          @@use_ip_list << ip_from_port(port_from_response(response))
        end

        def assigned_ip?(port)
          @@use_ip_list.include?(ip_from_port(port))
        end

        def get_free_port_ip(ip, subnet)
          port = get_free_port(subnet)
          port ? IP.new("#{ip_from_port(port)}/#{ip.pfxlen}") : ip
        end

        def fetch_by_ip(ip_addr)
          list.find {|p| ip_from_port(p) == ip_addr }
        end

        def port_from_response(response)
          response.data[:body]["port"]
        end

        def ip_from_port(port)
          port["fixed_ips"][0]["ip_address"] 
        end

        def get_free_port(subnet)
          list.find do |p|
            same_subnet?(p, subnet) &&
            unused?(p) &&
            admin_state_up?(p) &&
            !assigned_ip?(p)
          end
        end

        def request_any_address?(ip, subnet)
          ip.to_s == subnet["cidr"]
        end

        def same_subnet?(port, subnet)
          port["fixed_ips"][0]["subnet_id"] == subnet["id"]
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
