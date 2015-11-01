module Pec::Command
  class Up < Base
    @fetch = true
    def self.task(host_name, options, server, config)
      unless server
        Pec::Logger.info "make start #{config.name}"

        attribute = {name: config.name}
        make_attribute(config, Pec::Handler) do |key, klass|
          attribute.deep_merge!(klass.build(config))
        end

        make_attribute(attribute, Pec::Coordinate) do |key, klass|
          attribute.deep_merge!(klass.build(config, attribute))
        end

        Yao::Server.create(attribute)
        Pec::Logger.info "create success! #{config.name}"
      else
        Pec::Logger.notice "already server: #{config.name}"
      end
    end

    def self.make_attribute(source, klass)
      source.keys.each do |k|
        Object.const_get(klass.to_s).constants.each do |c|
          object = Object.const_get("#{klass.to_s}::#{c}")
          yield k, object if  k.to_s == object.kind.to_s
        end
      end
    end
  end
end
