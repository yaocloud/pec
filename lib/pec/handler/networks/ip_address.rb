module Pec::Handler
  class Networks
    class IpAddress < OptionBase
      self.kind = 'ip_address'
      class << self
        def build(network)
          ip = IP.new(network[1]['ip_address'])
          subnet = Yao::Subnet.list.find {|s|s.cidr == ip.network.to_s}

          if ip.to_s != subnet.cidr
            {
              fixed_ips: [
                { subnet_id: subnet.id, ip_address: ip.to_addr}
              ]
            }
          end
        end
      end
    end
  end
end
