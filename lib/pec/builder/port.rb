module Pec
  module Builder
    class Port
      attr_reader :all, :user_data
      def build(host)
        ports = []
        @user_data = []

        host.networks.each do |network|
          port = create_port(host, network)
          Pec::Logger.notice "assgin ip : #{port.fixed_ips.first["ip_address"]}"
          ports << port
          @user_data << gen_user_data(network, port)
        end
        {
          nics: ports.map {|port| { port_id: port.id }}
        }
      end

      def create_port(host, network)
        ip = IP.new(network[1]['ip_address'])
        subnet = Pec.neutron.subnets.find {|s|s.cidr == ip.network.to_s}
        attribute = gen_port_attribute(host, network, subnet, ip)
        Pec.neutron.ports.create(attribute)
      end
     
      def gen_port_attribute(host, network, subnet, ip)
        attribute = {
          name: network[0],
          network_id: subnet.network_id
        }

        attribute.merge!(
          fixed_ip(subnet, ip) 
        ) if ip.to_s != subnet.cidr

        attribute.merge!(
          security_group(host)
        ) if host.security_group

        attribute.merge!(
          allowed_address_pairs(network)
        ) if network[1]['allowed_address_pairs']
        attribute
      end
     
      def gen_user_data(network, port)
        path = network[1]['path'] || "/etc/sysconfig/network-scripts/ifcfg-#{port.name}"
        {
          'content' => ifcfg_config(network, port),
          'owner' => "root:root",
          'path' => path,
          'permissions' => "0644"
        }
      end
      
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
            "netmask" => IP.new(network[1]['ip_address']).netmask.to_s,
            "ipaddr"  => port.fixed_ips.first['ip_address']
          }
        ) if network[1]['bootproto'] == "static"

        # delete options
        %w(allowed_address_pairs ip_address).each {|name| network[1].delete(name)}
        
        base.merge!(
          network[1]
        )

        base.map {|k,v| "#{k.upcase}=#{v}"}.join("\n")
      end

      #
      # after port options
      #
      def fixed_ip(subnet, ip)
        { 
          fixed_ips: [
            { subnet_id: subnet.id, ip_address: ip.to_addr}
          ]
        }
      end

      def security_group(host)
        ids =  host.security_group.map do |name|
          Pec.neutron.security_groups.find {|sg| sg.name == name}.id
        end
        { security_groups: ids }
      end

      def allowed_address_pairs(network)
        pairs = network[1]['allowed_address_pairs'].map do |pair|
          { ip_address: pair['ip_address'] }
        end
        { allowed_address_pairs: pairs }
      end
    end
  end
end
