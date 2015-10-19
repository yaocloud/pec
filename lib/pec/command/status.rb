module Pec::Command
  class Status < Base
    def self.task(host_name, options, server, config)
      say("Current machine stasus:", :yellow)
      if server
        puts sprintf(" %-35s %-10s %-10s %-10s %-10s %-35s %-48s",
          config.name,
          server.status,
          Yao::Tenant.list.find {|tenant| tenant.id == server.tenant_id}.name,
          Yao::Flavor.get(server.flavor['id']).name,
          server.availability_zone,
          server.ext_srv_attr_host,
          server.addresses.map do |ethers|
            ethers[1].map do |ether|
              ether["addr"]
            end
          end.flatten.join(",")
        )
      else
        puts sprintf(" %-35s %-10s",
          config.name,
          "uncreated"
        )
      end
    end
  end
end
