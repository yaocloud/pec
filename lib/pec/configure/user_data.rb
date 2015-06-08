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
          merge_template = {}
          config.templates.each do |template|
            raise(Pec::Errors::UserData, "template:#{template} is not fond!") unless FileTest.exist?("user_datas/#{template}")
            merge_template.merge!(YAML.load_file("user_datas/#{template}").to_hash)
          end if config.templates
          merge_template
        end

        def make_port_content(config, ports)
          config.networks.map do |ether|
            port_content = {}
            port_content["bootproto"] = ether.bootproto
            port_content["name"] = ether.name unless ether.options.key?('name')
            port_content["name"] = ether.name unless ether.options.key?('name')
            port_content["device"] = ether.name unless ether.options.key?('device')
            port_content["type"] = 'Ethernet' unless ether.options.key?('type')
            port_content["onboot"] = "yes" unless ether.options.key?('onboot')

            path = "/etc/sysconfig/network-scripts/ifcfg-#{ether.name}" unless ether.options.key?('path')

            port = ports.find {|p| p.name == ether.name}

            if port
              if ether.bootproto == "static"
                port_content["netmask"] = port.netmask
                port_content["ipaddr"] = port.ip_address
              end
              port_content["hwaddr"] = port.mac_address
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
