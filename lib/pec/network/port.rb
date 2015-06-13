require 'json'
module Pec
  class Network
    class Port
      attr_reader :name, :subnet
      @@use_ip_list = []
      include Query

      def initialize(name, ip_addr, subnet, security_groups)
        @name = name
        @subnet = subnet
        @security_groups = security_groups
        @port = fetch(ip_addr)
      end

      def assign!(ip)
        # dhcp ip recycle
        if request_any_address?(ip)
          @port = fetch_free_port
          ip = IP.new("#{@port["fixed_ips"][0]["ip_address"]}/#{ip.pfxlen}") unless @port.nil?
        end

        case
        when exists? && !used?
          replace(ip)
        when !exists?
          create(ip)
        when used?
          raise(Pec::Errors::Port, "ip:#{ip.to_addr} is used!")
        end
      end

      def create(ip)
        options = { security_groups: @security_groups }
        options.merge!({ fixed_ips: [{ subnet_id: @subnet["id"], ip_address: ip.to_addr}]}) if ip.to_s != subnet["cidr"]
        response = Fog::Network[:openstack].create_port(@subnet["network_id"], options)

        if response
          @port = response.data[:body]["port"] 
          @@use_ip_list << response.data[:body]["port"]["fixed_ips"][0]["ip_address"]
          response.data[:body]["port"]["id"]
        end
      end

      def delete(ip)
        @port = fetch(ip.to_addr)
        response =  Fog::Network[:openstack].delete_port(@port["id"]) if @port
      end

      def replace(ip)
        create(ip) if delete(ip)
      end

      def request_any_address?(ip)
        ip.to_s == subnet["cidr"]
      end

      def fetch(ip_addr)
        list.find {|p| p["fixed_ips"][0]["ip_address"] == ip_addr }
      end

      def fetch_free_port
        list.find do |p|
          p["fixed_ips"][0]["subnet_id"] == @subnet["id"] &&
          p["device_owner"].empty? &&
          p["admin_state_up"] &&
          !@@use_ip_list.include?(p["fixed_ips"][0]["ip_address"])
        end
      end

      def exists?
        !@port.nil?
      end

      def used?
        @port && !@port["device_owner"].empty?
      end

      def id
        @port["id"]
      end

      def mac_address
        @port["mac_address"]
      end

      def ip_address
        @port["fixed_ips"][0]["ip_address"]
      end

      def network_id
        @port["network_id"]
      end

      def netmask
        IP.new(@port["fixed_ips"][0]["ip_address"]).netmask.to_s
      end
    end
  end
end
