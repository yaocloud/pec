require 'base64'
module Noah
  class Configure
    class UserData
      class << self
        def make(config, ports)
          user_data = {}
          user_data["write_files"] = make_port_content(config, ports) if ports
          Base64.encode64("#cloud-config\n" + user_data.merge(config.user_data).to_yaml)
        end

        def make_port_content(config, ports)
          config.networks.map do |ether|
            port_content = {}
            port_content["name"] = ether.name unless ether.options.key?('name')
            port_content["device"] = ether.name unless ether.options.key?('device')
            port_content["type"] = 'Ethernet' unless ether.options.key?('type')
            port_content["onboot"] = "yes" unless ether.options.key?('onboot')
            _path = "/etc/sysconfig/network-scripts/ifcfg-#{ether.name}" unless ether.options.key?('path')

            port = ports.find {|p| p.name == ether.name}

            if port
              port_content["netmask"] = port.netmask
              port_content["gateway"] = port.subnet["gateway_ip"]
              port_content["hwaddr"] = port.mac_address
              port_content["ipaddr"] = port.ip_address
            end
            port_content.merge!(ether.options)
            {
              'content' => port_content.map {|k,v| "#{k.upcase}=#{v}"}.join("\n"),
              'owner' => "root:root",
              'path' => _path,
              'permissions' => "0644"
            }
          end
        end
      end
    end
  end
end
