module Pec::Coordinate
  class UserData::Nic
    class Rhel < Base
      self.os_type = %w(centos rhel)
      class << self
        def ifcfg_config(network, port)
          base = {
            "name"      => port.name,
            "device"    => port.name,
            "type"      => 'Ethernet',
            "onboot"    => 'yes',
            "hwaddr"    => port.mac_address
          }
          base.merge!(
            {
              "netmask" => IP.new(network[CONFIG]['ip_address']).netmask.to_s,
              "ipaddr"  => port.fixed_ips.first['ip_address']
            }
          ) if network[CONFIG]['bootproto'] == "static"

          # delete option column
          mask_column = Pec::Handler::Networks.constants.map {|c| Object.const_get("Pec::Handler::Networks::#{c}").kind }
          mask_config = network[CONFIG].reject {|k,v| mask_column.include?(k)}

          base.merge!(
            mask_config
          )
          base.map {|k,v| "#{k.upcase}=#{v}"}.join("\n")
        end

        def default_path(port)
          "/etc/sysconfig/network-scripts/ifcfg-#{port.name}"
        end
      end
    end
  end
end
