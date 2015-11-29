module Pec::Command
  class Status < Base
    def self.task(server, config)
      if server
        tenant_name = safe_delete(config.name, config.tenant, :tenant) do
          Pec.fetch_tenant_by_id(server).name
        end

        flavor_name = safe_delete(config.name, config.flavor, :flavor) do
          Pec.fetch_flavor(server).name
        end

        puts sprintf(
          " %-35s %-10s %-10s %-10s %-10s %-10s %-35s %-48s",
          config.name,
          server.status,
          tenant_name,
          flavor_name,
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
      Pec::Logger.warning "Current machine status:"
    end

    def self.after_do
      Pec::Logger.warning @_error.join("\n") if @_error
    end

    def self.safe_delete(host_name, default ,resource_name, &blk)
      begin
        blk.call
      rescue
        @_error ||= []
        @_error << "#{host_name}:#{resource_name} is unmatch id. may be id has changed"
        default
      end
    end
  end
end
