module Pec::Handler
  class UserData::Nic
    extend Pec::Core
    autoload :Base,   "pec/handler/user_data/nic/base"
    autoload :Rhel,   "pec/handler/user_data/nic/rhel"
    autoload :Ubuntu, "pec/handler/user_data/nic/ubuntu"
    self.kind = 'networks'

    class << self
      def post_build(host, attribute)
        _nic = Pec::Handler::UserData::Nic.constants.reject {|c|c.to_s.downcase == "base"}.find do |c|
          host.os_type && Object.const_get("Pec::Handler::UserData::Nic::#{c}").os_type.include?(host.os_type)
        end

        nic = if _nic
          Object.const_get("Pec::Handler::UserData::Nic::#{_nic}")
        else
          Pec::Handler::UserData::Nic::Rhel
        end

        attribute.deep_merge(
          {
            user_data: {
              "write_files" => nic.gen_user_data(host.networks, ports(attribute))
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
