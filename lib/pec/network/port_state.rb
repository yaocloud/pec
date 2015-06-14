require 'json'
module Pec
  class Network
    class PortState
      attr_reader :device_name
      def initialize(device_name, port)
        @device_name = device_name
        @port = port
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
