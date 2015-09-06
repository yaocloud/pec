require 'pec'
module Pec
  class CLI < Thor

    desc 'init', 'create sample config'
    def init
      Pec::Init.show_env_setting
      Pec::Init.create_template_dir
      Pec::Init.create_sample_config
    end

    desc 'up', 'create vm by Pec.yaml'
    def up(host_name = nil)
      Pec.configure.each do |host|
        next if host_name && host.name != host_name
        Pec.init_yao(host.tenant)

        server = Yao::Server.list_detail.find {|s|s.name == host.name}
        if server
          Pec::Logger.notice "already exists: #{host.name}"
          next
        end

        Pec::Logger.info "make start #{host.name}"

        attribute = { name: host.name}
        host.keys.each do |k|
          Pec::Handler.constants.each do |c|
            if Object.const_get("Pec::Handler::#{c}").kind == k
              attribute.deep_merge!(Object.const_get("Pec::Handler::#{c}").build(host))
            end
          end
        end
        attribute[:user_data] = Base64.encode64("#cloud-config\n" + attribute[:user_data].to_yaml) if attribute[:user_data]

        Yao::Server.create(attribute)
        Pec::Logger.info "create success! #{host.name}"
      end
      rescue => e
        Pec::Logger.critical(e)
    end

    option :force , type: :boolean, aliases: "-f"
    desc "destroy", "delete vm"
    def destroy(host_name = nil)
      Pec.configure.each do |host|
        next if host_name && host.name != host_name
        Pec.init_yao(host.tenant)

        server = Yao::Server.list_detail.find {|s|s.name == host.name}
        unless server
          Pec::Logger.notice "not be created #{host.name}"
          next
        end

        if options[:force] || yes?("#{host.name}: Are you sure you want to destroy the '#{host.name}' VM? [y/N]")
          Yao::Server.destroy(server.id)
          Pec::Logger.info "#{host.name} is deleted!"
        end
      end

      rescue => e
        Pec::Logger.critical(e)
    end

    desc "status", "vm status"
    def status(host_name = nil)
      say("Current machine stasus:", :yellow)
      Pec.configure.each do |host|
        next if host_name && host.name != host_name
        Pec.init_yao(host.tenant)
        if server = Yao::Server.list_detail.find {|s|s.name == host.name}
          puts sprintf(" %-35s %-10s %-10s %-10s %-10s %-35s %-48s",
            host.name,
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
            host.name,
            "uncreated"
          )
        end
      end

      rescue => e
        Pec::Logger.critical(e)
    end
  end
end
