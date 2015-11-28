module Pec::Handler
  class UserData::Nic::Base
    class << self
      NAME = 0
      CONFIG = 1
      attr_accessor :os_type
      def gen_user_data(networks, ports)
        networks.map do |network|
          port = ports.find {|p|p.name == network[NAME]}
          path = network[CONFIG]['path'] || default_path(port)
          {
            'content' => ifcfg_config(network, port),
            'owner' => "root:root",
            'path' => path,
            'permissions' => "0644"
          }
        end
      end

      def safe_merge(base, network)
        # delete option column
        mask_column = Pec::Handler::Networks.constants.map {|c| Object.const_get("Pec::Handler::Networks::#{c}").kind }
        mask_config = network[CONFIG].reject {|k,v| mask_column.include?(k)}

        base.merge(
          mask_config
        )
      end

      def default_path(port)
        raise "undfined method default_path"
      end

      def ifcfg_config(network, port)
        raise "undfined method ifcfg_config"
      end
    end
    self.os_type = []
  end
end
