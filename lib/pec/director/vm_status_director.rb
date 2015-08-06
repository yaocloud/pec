module Pec
  class Director
    class VmStatusDirector
      def execute!(host)
        Pec::Resource.set_tenant(host.tenant)
        show_summary(host)
      end

      def do_it?(host)
        true
      end

      def show_summary(host)
        server            = Pec::Compute::Server.fetch(host.name)
        status            = "uncreated"
        availability_zone = ""
        compute_node      = ""
        tenant_name       = ""
        flavor            = ""
        ip_address        = ""

        if server
          detail = Pec::Resource.get.get_server_details(server["id"])
          status = detail["status"] 
          availability_zone = detail["OS-EXT-AZ:availability_zone"]
          compute_node = detail["OS-EXT-SRV-ATTR:host"]
          tenant_name = Pec::Compute::Tenant.get_name(detail["tenant_id"])
          flavor = Pec::Compute::Flavor.get_name(detail["flavor"]["id"])
          ip_address = parse_from_addresses(detail["addresses"]).join(",")
        end

        puts sprintf(" %-35s %-10s %-10s %-10s %-10s %-35s %-48s",
                     host.name, status, tenant_name, flavor, availability_zone, compute_node, ip_address)
      end
        
      def parse_from_addresses(addresses)                                                                                                 
        addresses.map do |net, ethers|                                                                                                    
          ethers.map do |ether|                                                                                                           
            ether["addr"]                                                                                                                 
          end                                                                                                                             
        end.flatten                                                                                                                       
      end   

      def err_message(e, host)
          puts e.magenta
          puts "can't create server:#{host.name}".magenta if host
      end
    end
  end
end
