module Noah
  class Network
    class Subnet
      include Query
      def fetch(cidr)
        list.find {|p| p["cidr"] == cidr }
      end
    end
  end
end
