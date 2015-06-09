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
            raise(Pec::Errors::UserData, "template:#{template} is not fond!") unless FileTest.exist?("user_datas/#{template}")
            merge_template.merge!(YAML.load_file("user_datas/#{template}").to_hash)
          end if config.templates
        end

        def make_port_content(config, ports)
          config.networks.map do |ether|
            port_content = {}
            %w(name device).each do |k|
              port_content[k] = ether.name unless ether.options.key?(k)
            end

            port_content["bootproto"] = ether.bootproto
            port_content["type"] = ether.options['type'] ||'Ethernet'
            port_content["onboot"] = ether.options['onboot'] || 'yes'
            path = ether.options['path'] || "/etc/sysconfig/network-scripts/ifcfg-#{ether.name}"

            port = ports.find {|p| p.name == ether.name}
            port_content["hwaddr"] = port.mac_address

            if ether.bootproto == "static"
              port_content["netmask"] = port.netmask
              port_content["ipaddr"] = port.ip_address
            end
            port_content.merge!(ether.options)
            {
              'content' => port_content.map {|k,v| "#{k.upcase}=#{v}"}.join("\n"),
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
