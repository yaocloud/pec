module Pec::Command
  class Status < Base
    @fetch = true
    def self.task(host_name, options, server, config)
      if server
        puts sprintf(
          " %-35s %-10s %-10s %-10s %-10s %-10s %-35s %-48s",
          config.name,
          server.status,
          tenant_name(server),
          flavor_name(server),
          server.availability_zone,
          server.key_name,
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

    def self.tenant_name(server)
      tenant_list.find {|tenant| tenant.id == server.tenant_id}.name
    end

    def self.tenant_list
      @@_tenant_list ||= Yao::Tenant.list
      @@_tenant_list
    end

    def self.flavor_name(server)
      Yao::Flavor.get(server.flavor['id']).name
    end

    def self.ip_addresses(server)
      server.addresses.map do |ethers|
        ethers[1].map do |ether|
          ether["addr"]
        end
      end.flatten.join(",")
    end

    def self.before_do
      Thor.new.say("Current machine status:", :yellow)
    end
  end
end
