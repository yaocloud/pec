require 'json'
module Pec
  class Compute
    class Server
      include Query
      def create(name, image_ref, flavor_ref, ports, options)
        networks = ports.map do |port|
          if port.used?
            puts "port-id:#{port.id} ip-addr:#{port.ip_address} in used"
            return false
          end
          { port_id: port.id }
        end if ports

        options.merge!({ 'nics' =>  networks })
        response = Fog::Compute[:openstack].create_server(name, image_ref, flavor_ref, options)
        if response[:status] == 202
          puts "success create for server_name:#{name}"
        end
        response.data[:body]["server"]["id"]

        rescue Excon::Errors::Error => e
          JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
          false
      end

      def exists?(server_name)
        fetch(server_name)
      end

      def destroy!(server_name)
        server = fetch(server_name)
        unless server
          puts "server_name:#{server_name} is not fond!"
          return
        end

        response = Fog::Compute[:openstack].delete_server(server["id"]) if server
        if response && response[:status] == 204
          puts "server_name:#{server_name} is deleted!"
        end
        rescue Excon::Errors::Error => e
          JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
          false
      end
    end
  end
end
