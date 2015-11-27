module Pec::Handler
  class UserData
    extend Pec::Core
    autoload :Nic,  "pec/handler/user_data/nic"
    self.kind = 'user_data'

    def self.build(host)
      user_data = host.user_data || {}
      user_data['fqdn'] = host.name if host.user_data && !host.user_data['fqdn']  
      { user_data: user_data }
    end

    def self.post_build(host, attribute)
      attribute.keys.each do |k|
        Pec::Handler::UserData.constants.each do |c|
          klass = Object.const_get("Pec::Handler::UserData::#{c}")

          if klass.kind.to_s == k.to_s
            attribute = klass.post_build(host, attribute)
          end
        end
      end
      attribute[:user_data] = Base64.encode64("#cloud-config\n" + attribute[:user_data].to_yaml) if attribute[:user_data]
      attribute
    end
  end
end
