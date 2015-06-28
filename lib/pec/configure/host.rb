module Pec
  class Configure
    class Host
      attr_reader :name, :image, :flavor,:security_group, :user_data, :networks, :templates, :tenant
      def initialize(config)
        check_format(config)
        append_network(config[1])
        @name           = config[0];
        @image          = config[1]["image"];
        @flavor         = config[1]["flavor"];
        @security_group = config[1]["security_group"];
        @user_data      = config[1]["user_data"];
        @templates      = config[1]["templates"]
        @tenant         = config[1]["tenant"]
      end

      def append_network(config)
        @networks ||= []
        config["networks"].each do |net|
          raise(Pec::Errors::Ethernet, "please! network interface format is Array") unless net.kind_of?(Array)

          if ethernet = Pec::Configure::Ethernet.new(config, net)
            @networks << ethernet
          end

        end if config["networks"]
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
