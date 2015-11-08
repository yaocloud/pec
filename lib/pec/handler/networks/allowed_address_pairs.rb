module Pec::Handler
  class Networks
    class AllowedAddressPairs
      extend Pec::Core
      self.kind = 'allowed_address_pairs'
      class << self
        def build(network)
          if network[1]['allowed_address_pairs']
            pairs = network[1]['allowed_address_pairs'].map do |pair|
              { ip_address: pair }
            end
            { allowed_address_pairs: pairs }
          end
        end
      end
    end
  end
end
