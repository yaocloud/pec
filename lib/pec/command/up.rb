module Pec::Command
  class Up < Base
    @fetch = true
    def self.task(host_name, options, server, config)
      case
      when server.nil?
        Pec::Logger.info "make start #{config.name}"
        attribute = {name: config.name}

        begin
          processor_matching(config, Pec::Handler) do |klass|
            attribute.deep_merge!(klass.build(config))
          end

          processor_matching(attribute, Pec::Handler) do |klass|
            attribute.deep_merge!(klass.post_build(config, attribute))
          end

          Yao::Server.create(attribute)
          Pec::Logger.info "create success! #{config.name}"
        rescue => e
          Pec::Logger.critical(e)
          Pec::Logger.warning "recovery start #{config.name}"

          processor_matching(config, Pec::Handler) do |klass|
            attribute.deep_merge!(klass.recover(attribute))
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

    def self.processor_matching(source, klass)
      source.keys.each do |k|
        Object.const_get(klass.to_s).constants.each do |c|
          object = Object.const_get("#{klass.to_s}::#{c}")
          yield object if  k.to_s == object.kind.to_s
        end
      end
    end
  end
end
