module Pec::Handler
  class UserData
    extend Pec::Core
    autoload :Nic,  "pec/handler/user_data/nic"
    self.kind = 'user_data'

    def self.build(config)
      user_data = config.user_data ? config.user_data.dup : {}
      user_data['fqdn'] = config.name if config.user_data && !config.user_data['fqdn']
      { user_data: user_data }
    end

    def self.post_build(config, attribute)
      Pec.processor_matching(attribute, Pec::Handler::UserData) do |klass|
        attribute = klass.post_build(config, attribute)
      end
      attribute[:user_data] = Base64.encode64("#cloud-config\n" + attribute[:user_data].to_yaml) if attribute[:user_data]
      attribute
    end
  end
end
