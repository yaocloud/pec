module Pec::Command
  class Up < Base
    def self.task(host_name, options, server, config)
      unless server
        Pec::Logger.info "make start #{config.name}"

        attribute = { name: config.name}
        config.keys.each do |k|
          Pec::Handler.constants.each do |c|
            if Object.const_get("Pec::Handler::#{c}").kind == k
              attribute.deep_merge!(Object.const_get("Pec::Handler::#{c}").build(config))
            end
          end
        end

        attribute[:user_data] = Base64.encode64("#cloud-config\n" + attribute[:user_data].to_yaml) if attribute[:user_data]

        Yao::Server.create(attribute)
        Pec::Logger.info "create success! #{config.name}"
      else
        Pec::Logger.notice "already server: #{config.name}"
      end
    end
  end
end
