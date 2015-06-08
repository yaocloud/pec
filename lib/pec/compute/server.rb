require 'json'
module Pec
  class Compute
    class Server
      include Query
      def create(name, image_ref, flavor_ref, ports, options)
        networks = ports.map do |port|
          raise(Pec::Errors::Port, "port-id:#{port.id} ip-addr:#{port.ip_address} in used") if port.used?
          puts "#{name}: assingn ip #{port.ip_address}"
          { port_id: port.id }
        end if ports

        options.merge!({ 'nics' =>  networks })

        response = Fog::Compute[:openstack].create_server(name, image_ref, flavor_ref, options)

        if response[:status] == 202
          puts "success create for server_name:#{name}"
        end

        response.data[:body]["server"]["id"]
      end

      def exists?(server_name)
        fetch(server_name)
      end

      def destroy!(server_name)
        server = fetch(server_name)
        raise(Pec::Errors::Host, "server_name:#{server_name} is not fond!") unless server
        response = Fog::Compute[:openstack].delete_server(server["id"]) if server

        if response && response[:status] == 204
          puts "server_name:#{server_name} is deleted!"
        end
      end
    end
  end
end
