module Pec
  class Director
    def self.make(host_name)
      Pec.load_config
      Pec.configure.each do |host|
        next if host_name && host.name != host_name
        Pec::Logger.info "make start #{host.name}"
        Pec.compute.set_tenant(host.tenant)
        Pec.neutron.set_tenant_patch(host.tenant)

        attribute = { name: host.name}
        host.keys.each do |k|
          Pec::Handler.constants.each do |c|
            if Object.const_get("Pec::Handler::#{c}").kind == k
              attribute.deep_merge!(Object.const_get("Pec::Handler::#{c}").build(host))
            end
          end
        end

        if attribute[:user_data]
          attribute[:user_data] = "#cloud-config\n" + attribute[:user_data].to_yaml
        end
        Pec::Logger.info "create success! #{host.name}" if Pec.compute.servers.create(attribute)
      end

      rescue Excon::Errors::Error => e
        excon_err_message(e)
      rescue => e
        Pec::Logger.critical(e)
    end

    def self.destroy(host_name, options)
      Pec.load_config
      Pec.configure.each do |host|
        next if host_name && host.name != host_name
        Pec.compute.set_tenant(host.tenant)
        
        server = Pec.compute.servers.find {|s|s.name == host.name}
        unless server
          Pec::Logger.notice "not be created #{host.name}"
          next
        end
        
        if options[:force] || Thor.new.yes?("#{host.name}: Are you sure you want to destroy the '#{host.name}' VM? [y/N]")
          Pec::Logger.info "#{host.name} is deleted!" if Pec.compute.servers.destroy(server.id)
        end
      end

      rescue Excon::Errors::Error => e
        excon_err_message(e)
      rescue => e
        Pec::Logger.critical(e)
    end

    def self.status(host_name)
      Pec.load_config
      Pec.configure.each do |host|
        next if host_name && host.name != host_name
        server = Pec.compute.servers.find {|s|s.name == host.name}
        if server
          puts sprintf(" %-35s %-10s %-10s %-10s %-10s %-35s %-48s",
            host.name,
            server.state,
            Pec.identity.tenants.find_by_id(server.tenant_id),
            Pec.compute.flavors.get(server.flavor['id']).name,
            server.availability_zone,
            server.os_ext_srv_attr_host,
            server.addresses.map do |net, ethers|                                                                                                    
              ethers.map do |ether|                                                                                                           
                ether["addr"]                                                                                                                 
              end                                                                                                                             
            end.flatten.join(",")
          )

        else
          puts sprintf(" %-35s %-10s",
            host.name,
            "uncreated"
          )
        end
      end

      rescue Excon::Errors::Error => e
        excon_err_message(e)
      rescue => e
        Pec::Logger.critical(e)
    end

    def self.excon_err_message(e)
      if e.response
        JSON.parse(e.response[:body]).each { |e,m| Pec::Logger.critical("#{e}:#{m["message"]}") }
      else
        Pec::Logger.critical(e)
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        def set_tenant_patch(tenant)
          @openstack_must_reauthenticate = true
          @openstack_tenant = tenant.to_s
          authenticate
          @path.sub!(/\/$/, '')
          unless @path.match(SUPPORTED_VERSIONS)
            @path = "/" + Fog::OpenStack.get_supported_version(SUPPORTED_VERSIONS,
                                                               @openstack_management_uri,
                                                               @auth_token,
                                                               @connection_options)
          end
        end
      end
    end
  end
end
