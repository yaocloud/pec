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
        server       = Pec::Compute::Server.fetch(host.name)
        status       = "uncreated"
        compute_node = ""
        tenant_name  = ""
        flavor       = ""
        ip_address   = ""
        if server
          detail = Pec::Resource.get.get_server_details(server["id"])
          status = detail["status"] 
          compute_node = detail["OS-EXT-SRV-ATTR:host"]
          flavor = detail["flavor"]["id"]
          tenant_name = Pec::Compute::Tenant.get_name(detail["tenant_id"])
          ip_address = Pec::Director::Helper.parse_from_addresses(detail["addresses"]).join(",")
        end

        puts sprintf(" %-30s |%-10s | %-10s | %-10s | %-30s | %-48s", host.name, status, tenant_name, flavor, compute_node, ip_address)
      end

      def err_message(e, host)
          puts e.to_s.magenta
          puts "can't create server:#{host.name}".magenta if host
      end
    end
  end
end
