module Pec::Coordinate
  class UserData < Base
    autoload :Base, "pec/coordinate/user_data/base"
    autoload :Nic,  "pec/coordinate/user_data/nic"
    self.kind = 'user_data'

    def self.build(host, attribute)
      attribute.keys.each do |k|
        Pec::Coordinate::UserData.constants.each do |c|
          user_data = Object.const_get("Pec::Coordinate::UserData::#{c}")

          if user_data.kind.to_s == k.to_s
            attribute.deep_merge!(user_data.build(host, attribute))
          end
        end
      end
      attribute[:user_data] = Base64.encode64("#cloud-config\n" + attribute[:user_data].to_yaml) if attribute[:user_data]
      attribute
    end
  end
end
