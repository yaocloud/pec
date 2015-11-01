module Pec::Coordinate
  class UserData::Nic
    class Ubuntu < Base
      self.os_type = %w(ubuntu)
      class << self
        def gen_user_data(networks, ports)
          port_content = [
            "auto lo\niface lo inet loopback"
          ]

          networks.map do |network|
            port = ports.find {|p|p.name == network[NAME]}
            port_content << ifcfg_config(network, port)
          end

          {
            'content' => port_content.join("\n"),
            'owner' => "root:root",
            'path' => networks.first[CONFIG]['path'] || default_path(nil),
            'permissions' => "0644"
          }
        end

        def ifcfg_config(network, port)
          base = {
            "auto"                    => port.name,
            "iface #{port.name} inet" => network[CONFIG]['bootproto'],
          }
          base.merge!(
            {
              "address"  => port.fixed_ips.first['ip_address'],
              "netmask" => IP.new(network[CONFIG]['ip_address']).netmask.to_s,
              "hwaddress ether"  => port.mac_address
            }
          ) if network[CONFIG]['bootproto'] == "static"
          safe_merge(base, network).map {|k,v| "#{k} #{v}"}.join("\n")
        end

        def default_path(port)
          "/etc/network/interfaces"
        end
      end
    end
  end
end
