module Noah
  class Configure
    class Host
      attr_reader :name, :image, :flavor,:security_group, :user_data, :networks
      def initialize(config)
        @name = config[0];
        @image = config[1]["image"];
        @flavor = config[1]["flavor"];
        @security_group = config[1]["security_group"];
        @user_data = config[1]["user_data"];
      end

      def append_network(network)
        @networks ||= []
        @networks << network
      end

      class << self
        def load(config)
          host = self.new(config) if check_require_key(config)
          config[1]["networks"].each do |net|
            net_config = Noah::Configure::Ethernet.load(config[0], net)
            return nil unless net_config
            host.append_network(net_config)
          end if host && config[1]["networks"]
          host
        end

        def check_require_key(config)
          err = %w(image flavor).find {|r| !config[1].key?(r)}
          return true if err.nil?
          puts "skip! #{config[0]}: #{err} is required!"
          false
        end
      end
    end
  end
end
