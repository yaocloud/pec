module Pec
  class Configure
    class Host
      attr_reader :name, :image, :flavor,:security_group, :user_data, :networks, :templates, :tenant
      def initialize(config)
        @name = config[0];
        @image = config[1]["image"];
        @flavor = config[1]["flavor"];
        @security_group = config[1]["security_group"];
        @user_data = config[1]["user_data"];
        @templates = config[1]["templates"]
        @tenant = config[1]["tenant"]
      end

      def append_network(network)
        @networks ||= []
        @networks << network
      end

      class << self
        def load(config)
          host = self.new(config) if check_format(config)

          config[1]["networks"].each do |net|
            raise(Pec::Errors::Ethernet, "please! network interface format is Array") unless net.kind_of?(Array)

            net_config = Pec::Configure::Ethernet.new(config[0], net)
            host.append_network(net_config) if net_config

          end if host && config[1]["networks"]
          host
        end

        def check_format(config)
          err = %w(image flavor tenant).find {|r| !config[1].key?(r) || config[1][r].nil? }
          raise(Pec::Errors::Host,"skip! #{config[0]}: #{err} is required!") unless  err.nil?

          err = %w(security_group templates).find {|r| config[1].key?(r) && !config[1][r].kind_of?(Array) }
          raise(Pec::Errors::Host,"#{config[0]}: please! #{err} format is Array!") unless err.nil?
          true
        end
      end
    end
  end
end
