module Pec
  class Network
    class Subnet
      include Query
      def fetch(cidr)
        subnet = list.find {|p| p["cidr"] == cidr }
        raise(Pec::Errors::Subnet, "cidr:#{cidr} is not fond!") unless subnet
        subnet
      end
    end
  end
end
