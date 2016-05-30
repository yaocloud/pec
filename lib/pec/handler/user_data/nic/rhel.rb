module Pec::Handler
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
          safe_merge(base, network).map {|k,v| "#{k.upcase}=#{v}\n"}.join
        end

        def default_path(port)
          "/etc/sysconfig/network-scripts/ifcfg-#{port.name}"
        end
      end
    end
  end
end
