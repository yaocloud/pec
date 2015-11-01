module Pec::Coordinate
  class UserData::Nic::Base
    class << self
      NAME = 0
      CONFIG = 1
      attr_accessor :os_type
      def gen_user_data(network, port)
        path = network[CONFIG]['path'] || default_path(port)
        {
          'content' => ifcfg_config(network, port),
          'owner' => "root:root",
          'path' => path,
          'permissions' => "0644"
        }
      end

      def default_path(port)
        raise "undfined method default_path"
      end

      def ifcfg_config(network, port)
        raise "undfined method ifcfg_config"
      end
    end
  end
end
