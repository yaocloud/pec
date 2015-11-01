module Pec::Command
  class Up < Base
    @fetch = true
    def self.task(host_name, options, server, config)
      unless server
        Pec::Logger.info "make start #{config.name}"

        attribute = {name: config.name}
        attribute = make_attribute(config, attribute, Pec::Handler)
        attribute = make_attribute(attribute, attribute, Pec::Coordinate)

        Yao::Server.create(attribute)
        Pec::Logger.info "create success! #{config.name}"
      else
        Pec::Logger.notice "already server: #{config.name}"
      end
    end

    def self.make_attribute(source, attribute, object_name)
      source.keys.each do |k|
        Object.const_get(object_name.to_s).constants.each do |c|
          object = Object.const_get("#{object_name.to_s}::#{c}")
          attribute.deep_merge!(object.build(source)) if object.kind == k
        end
      end
      attribute
    end
  end
end
