module Pec::Handler
  class Networks
    extend Pec::Core
    self.kind = 'networks'
    autoload :IpAddress,           "pec/handler/networks/ip_address"
    autoload :AllowedAddressPairs, "pec/handler/networks/allowed_address_pairs"

    class << self
      NAME = 0
      CONFIG = 1

      def build(host)
        ports = []
        host.networks.each do |network|
          validate(network)
          Pec::Logger.notice "port create start : #{network[NAME]}"
          port = create_port(host, network)
          Pec::Logger.notice "assgin ip : #{port.fixed_ips.first["ip_address"]}"
          ports << port
        end
        {
          networks: ports.map {|port| { uuid: nil, port: port.id }}
        }
      end

      def recover(attribute)
        Pec::Logger.notice "start port recovery"
        attribute[:networks].each do |port|
          Yao::Port.destroy(port[:port])
          Pec::Logger.notice "port delete id:#{port[:port]}"
        end
        Pec::Logger.notice "complete port recovery"
      end

      def validate(network)
        %w(
          bootproto
          ip_address
        ).each do |k|
          raise "network key #{k} is require" unless network[CONFIG][k]
        end
      end

      def create_port(host, network)
        attribute = gen_port_attribute(host, network)
        Yao::Port.create(attribute)
      end

      def gen_port_attribute(host, network)
        ip = IP.new(network[CONFIG]['ip_address'])
        subnet = Yao::Subnet.list.find {|s|s.cidr == ip.network.to_s}
        attribute = {
          name: network[NAME],
          network_id: subnet.network_id
        }

        attribute.merge!(
          security_group(host)
        ) if host.security_group

        network[CONFIG].keys.each do |k|
          Pec::Handler::Networks.constants.each do |c|
            if Object.const_get("Pec::Handler::Networks::#{c}").kind == k &&
                ops = Object.const_get("Pec::Handler::Networks::#{c}").build(network)
              attribute.deep_merge!(ops)
            end
          end
        end

        attribute
      end

      def security_group(host)
        tenant = Yao::Tenant.list.find {|t| t.name == host.tenant }
        ids = host.security_group.map do |name|
          sg = Yao::SecurityGroup.list.find {|sg| sg.name == name && tenant.id == sg.tenant_id }
          raise "security group #{name} is not found" unless sg
          sg.id
        end
        { security_groups: ids }
      end
    end
  end
end
