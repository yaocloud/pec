module Pec
  class Configure
    class Host
      attr_reader :name, :image, :flavor,:security_group, :user_data, :networks, :templates
      def initialize(config)
        @name = config[0];
        @image = config[1]["image"];
        @flavor = config[1]["flavor"];
        @security_group = config[1]["security_group"];
        @user_data = config[1]["user_data"];
        @templates = config[1]["templates"]
      end

      def append_network(network)
        @networks ||= []
        @networks << network
      end

      class << self
        def load(config)
          host = self.new(config) if check_require_key(config)
          config[1]["networks"].each do |net|
            net_config = Pec::Configure::Ethernet.load(config[0], net)
            host.append_network(net_config) if net_config
          end if host && config[1]["networks"]
          host
        end

        def check_require_key(config)
          err = %w(image flavor).find {|r| !config[1].key?(r) || config[1][r].nil? }
          raise(Pec::Errors::Host,"skip! #{config[0]}: #{err} is required!") unless  err.nil?
          true
        end
      end
    end
  end
end
