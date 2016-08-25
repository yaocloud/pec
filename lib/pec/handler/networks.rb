require "pec/port_error"
module Pec::Handler
  class Networks
    extend Pec::Core
    self.kind = 'networks'
    autoload :IpAddress,           "pec/handler/networks/ip_address"
    autoload :AllowedAddressPairs, "pec/handler/networks/allowed_address_pairs"

    class << self
      NAME = 0
      CONFIG = 1

      def build(config)
        ports = []
        config.networks.each do |network|
          validate(network)
          Pec::Logger.notice "port create start : #{network[NAME]}"
          port = create_port(config, network)
          Pec::Logger.notice "assgin ip : #{port.fixed_ips.first["ip_address"]}"
          ports << port
        end
        {
          networks: ports.map {|port| { uuid: '', port: port.id }}
        }
      rescue Yao::Conflict => e
        raise(Pec::PortError.new(ports), e)
      end

      def recover(attribute)
        return unless attribute[:networks]

        Pec::Logger.notice "start port recovery"
        attribute[:networks].each do |port|
          if port[:port]
            Yao::Port.destroy(port[:port])
            Pec::Logger.notice "port delete id:#{port[:port]}"
          end
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

      def create_port(config, network)
        attribute = gen_port_attribute(config, network)
        Yao::Port.create(attribute)
      end

      def gen_port_attribute(config, network)
        ip = IP.new(network[CONFIG]['ip_address'])
        subnet = Yao::Subnet.list.find {|s|s.cidr == ip.network.to_s}
        attribute = {
          name: network[NAME],
          network_id: subnet.network_id
        }

        attribute.merge!(
          security_group(config)
        ) if config.security_group

        Pec.processor_matching(network[CONFIG], Pec::Handler::Networks) do |klass|
          ops = klass.build(network)
          attribute.deep_merge!(ops) if ops
        end

        attribute
      end

      def security_group(config)
        ids = config.security_group.map do |name|
          sg = Yao::SecurityGroup.list.find {|sg| sg.name == name && Pec.get_tenant_id == sg.tenant_id }
          raise "security group #{name} is not found" unless sg
          sg.id
        end
        { security_groups: ids }
      end
    end
  end
end
