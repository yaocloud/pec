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

          raise(Pec::Errors::Port, "ip:#{ip.to_addr} is not created!") unless response
          append_assigned_ip(response)

          response.data[:body]["port"]
        end

        def set_security_group(security_group_ids)
          { security_groups: security_group_ids }
        end

        def set_fixed_ip(options, subnet, ip)
          ip.to_s != subnet["cidr"] ? options.merge({ fixed_ips: [{ subnet_id: subnet["id"], ip_address: ip.to_addr}]}) : options
        end

        def append_assigned_ip(response)
          @@use_ip_list << response.data[:body]["port"]["fixed_ips"][0]["ip_address"]
        end

        def assigned_ip?(port)
          @@use_ip_list.include?(port["fixed_ips"][0]["ip_address"])
        end

        def get_free_port_ip(ip, subnet)
          port = fetch_free_port(subnet)
          port ? IP.new("#{port["fixed_ips"][0]["ip_address"]}/#{ip.pfxlen}") : ip
        end

        def delete(ip)
          target_port = fetch_by_ip(ip.to_addr)
          response = Pec::Resource.get.delete_port(target_port["id"]) if target_port
        end

        def recreate(ip, subnet, security_group_ids)
          create(ip, subnet, security_group_ids) if delete(ip)
        end

        def request_any_address?(ip, subnet)
          ip.to_s == subnet["cidr"]
        end

        def fetch_by_ip(ip_addr)
          list.find {|p| p["fixed_ips"][0]["ip_address"] == ip_addr }
        end

        def fetch_free_port(subnet)
          list.find do |p|
            p["fixed_ips"][0]["subnet_id"] == subnet["id"] &&
            p["device_owner"].empty? &&
            p["admin_state_up"] &&
            !assigned_ip?
          end
        end
      end
    end
  end
end
