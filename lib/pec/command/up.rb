module Pec::Command
  class Up < Base
    def self.task(options, server, config)
      case
      when server.nil?
        Pec::Logger.info "make start #{config.name}"
        attribute = {name: config.name}

        begin
          Pec.processor_matching(config, Pec::Handler) do |klass|
            if attr = klass.build(config)
              attribute.deep_merge!(attr)
            end
          end

          Pec.processor_matching(attribute, Pec::Handler) do |klass|
            if attr = klass.post_build(config, attribute)
              attribute.deep_merge!(attr)
            end
          end

          Yao::Server.create(attribute)
          Pec::Logger.info "create success! #{config.name}"
        rescue => e
          Pec::Logger.critical(e)
          Pec::Logger.warning "recovery start #{config.name}"

          Pec.processor_matching(config, Pec::Handler) do |klass|
            klass.recover(attribute)
          end
          Pec::Logger.warning "recovery success! #{config.name}"
        end

      when server.status == "SHUTOFF"
        Yao::Server.start(server.id)
        Pec::Logger.info "start server: #{config.name}"
      else
        Pec::Logger.notice "already server: #{config.name}"
      end
    end

  end
end
