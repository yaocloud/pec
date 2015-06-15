require 'base64'
module Pec
  class Configure
    class UserData
      class << self
        def make(config, ports)
          user_data = {}
          user_data["write_files"] = make_port_content(config, ports) if ports
          user_data.merge!(config.user_data) if config.user_data
          user_data.merge!(get_template(config)) if get_template(config)
          Base64.encode64("#cloud-config\n" + user_data.to_yaml)
        end

        def get_template(config)
          config.templates.inject({}) do |merge_template, template|
            template.to_s.concat('.yaml') unless template.to_s.match(/.*\.yaml/)
            raise(Pec::Errors::UserData, "template:#{template} is not fond!") unless FileTest.exist?("user_datas/#{template}")
            merge_template.merge!(YAML.load_file("user_datas/#{template}").to_hash)
          end if config.templates
        end

        def make_port_content(config, ports)
          config.networks.map do |ether|
            path = ether.options['path'] || "/etc/sysconfig/network-scripts/ifcfg-#{ether.name}"
            {
              'content' => ether.get_port_content(ports),
              'owner' => "root:root",
              'path' => path,
              'permissions' => "0644"
            }
          end
        end
      end
    end
  end
end
