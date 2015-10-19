module Pec::Command
  class Status < Base
    def self.task(host_name, options, server, config)
      say("Current machine stasus:", :yellow)
      if server
        puts sprintf(
          " %-35s %-10s %-10s %-10s %-10s %-35s %-48s",
          config.name,
          server.status,
          tenant_name(server),
          flavor_name(server),
          server.availability_zone,
          server.ext_srv_attr_host,
          ip_addresses(server)
        )
      else
        puts sprintf(" %-35s %-10s",
          config.name,
          "uncreated"
        )
      end
    end

    def self.tenant_name(sever)
      Yao::Tenant.list.find {|tenant| tenant.id == server.tenant_id}.name
    end

    def self.flavor_name(sever)
      Yao::Flavor.get(server.flavor['id']).name
    end

    def self.ip_addresses(server)
      server.addresses.map do |ethers|
        ethers[1].map do |ether|
          ether["addr"]
        end
      end.flatten.join(",")
    end
  end
end
