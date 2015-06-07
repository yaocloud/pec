require 'json'
module Noah
  class Network
    class Port
      attr_reader :name, :subnet
      include Query
      def initialize(name, ip_addr, subnet)
        @name = name
        @subnet = subnet
        @config = fetch(ip_addr)
      end

      def fetch(ip_addr)
        list.find {|p| p["fixed_ips"][0]["ip_address"] == ip_addr }
      end

      def exists?
        !@config.nil?
      end

      def used?
        @config && !@config["device_owner"].empty?
      end

      def id
        @config["id"]
      end

      def mac_address
        @config["mac_address"]
      end

      def ip_address
        @config["fixed_ips"][0]["ip_address"]
      end

      def network_id
        @config["network_id"]
      end

      def netmask
        IP.new(@config["fixed_ips"][0]["ip_address"]).netmask.to_s
      end

      def create(ip)
        options = {}
        ## parameter is network address to dhcp
        if ip.to_s != subnet["cidr"]
          options = { fixed_ips: [{ subnet_id: @subnet["id"], ip_address: ip.to_addr}]}
        end

        res = Fog::Network[:openstack].create_port(@subnet["network_id"], options)

        @config = res.data[:body]["port"] if res
        @@_list['port'] ||= []
        @@_list['port'] << @config
        true
        rescue Excon::Errors::Conflict => e
          JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
          false
      end

      def delete(port_id)
        Fog::Network[:openstack].delete_port(port_id)
        rescue Excon::Errors::Conflict => e
          JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
          false
      end

      def replace(ip)
        delete(@config["id"])
        @@_list['port'] = nil
        create(ip)
      end

    end
  end
end
