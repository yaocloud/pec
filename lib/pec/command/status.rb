module Pec::Command
  class Status < Base
    @fetch = true
    def self.task(host_name, options, server, config)
      if server
        puts sprintf(
          " %-35s %-10s %-10s %-10s %-10s %-10s %-35s %-48s",
          config.name,
          server.status,
          Pec.fetch_tenant(server).name,
          Pec.fetch_flavor(server).name,
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
