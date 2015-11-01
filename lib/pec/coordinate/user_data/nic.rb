module Pec::Coordinate
  class UserData::Nic < Base
    autoload :Base,   "pec/coordinate/user_data/nic/base"
    autoload :Rhel,   "pec/coordinate/user_data/nic/rhel"
    autoload :Ubuntu, "pec/coordinate/user_data/nic/ubuntu"
    self.kind = 'networks'

    class << self
      NAME = 0
      CONFIG = 1
      def build(host, attribute)
        nic = Pec::Coordinate::UserData::Nic.constants.find do |c|
          host.os_type && Object.const_get("Pec::Coordinate::UserData::Nic::#{c}").os_type.include?(host.os_type)
        end
        nic ||= Pec::Coordinate::UserData::Nic::Rhel

        attribute.deep_merge(
          {
            user_data: {
              write_files: nic.gen_user_data(host.networks, ports(attribute))
            }
          }
        )
      end

      def ports(attribute)
        port_ids(attribute).map do |id|
          Yao::Port.get(id)
        end
      end

      def port_ids(attribute)
        attribute[:networks].map {|n|n[:port]}
      end

    end
  end
end
