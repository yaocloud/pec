module Pec::Command
  class Up < Base
    def self.task(server, config)
      case
      when server.nil?
        Pec::Logger.info "make start #{config.name}"
        attribute = {name: config.name}

        begin
          attribute = build(config, attribute)
          attribute = post_build(config, attribute)

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

    class << self
      %i(
        build
        post_build
      ).each do |name|
        define_method(name) do |config,attribute|
          source = config
          input = [config]

          if name == :post_build
            source = attribute
            input = [config, attribute]
          end

          Pec.processor_matching(source, Pec::Handler) do |klass|
            if attr = klass.send(name, *input)
              attribute.deep_merge!(attr)
            end
          end
          attribute
        end
      end
    end
  end
end
