module Pec
  class Compute
    class Server
      extend Query
      class << self
        def create(name, image_ref, flavor_ref, options)

          response = Pec::Resource.get.create_server(name, image_ref, flavor_ref, options)

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
          response = Pec::Resource.get.delete_server(server["id"]) if server

          if response && response[:status] == 204
            puts "server_name:#{server_name} is deleted!"
          end
        end
      end
    end
  end
end
