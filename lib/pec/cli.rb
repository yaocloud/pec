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
      Pec.servers(host_name) do |server,config|
        if server
          Pec::Logger.notice "already server: #{config.name}"
          next
        end

        Pec::Logger.info "make start #{config.name}"

        attribute = { name: config.name}
        config.keys.each do |k|
          Pec::Handler.constants.each do |c|
            if Object.const_get("Pec::Handler::#{c}").kind == k
              attribute.deep_merge!(Object.const_get("Pec::Handler::#{c}").build(config))
            end
          end
        end
        attribute[:user_data] = Base64.encode64("#cloud-config\n" + attribute[:user_data].to_yaml) if attribute[:user_data]

        Yao::Server.create(attribute)
        Pec::Logger.info "create success! #{config.name}"
      end
      rescue => e
        print_exception(e)
    end

    option :force , type: :boolean, aliases: "-f"
    desc "destroy", "delete vm"
    def destroy(host_name = nil)
      Pec.servers(host_name) do |server,config|
        unless server
          Pec::Logger.notice "not be created #{config.name}"
          next
        end

        if options[:force] || yes?("#{config.name}: Are you sure you want to destroy the '#{config.name}' VM? [y/N]")
          Yao::Server.destroy(server.id)
          Pec::Logger.info "#{config.name} is deleted!"
        end
      end

      rescue => e
        print_exception(e)
    end

    desc "status", "vm status"
    def status(host_name = nil)
      say("Current machine stasus:", :yellow)
      Pec.servers(host_name) do |server,config|
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
    rescue => e
      print_exception(e)
    end

    desc "config", "show configure"
    def config
      puts YAML.dump(
        YAML.load_file("Pec.yaml").to_hash.reject {|c| c[0].to_s.match(/^_/)}
      )
    end

    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      puts Pec::VERSION
    end

    no_commands do
      def print_exception(e)
        Pec::Logger.critical(e)
        Pec::Logger.info("\t" + e.backtrace.join("\n\t"))
      end
    end
  end
end
