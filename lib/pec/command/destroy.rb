module Pec::Command
  class Destroy < Base
    def self.task(server, config)
      unless server
        Pec::Logger.notice "not be created #{config.name}"
      else
        if Pec.options[:force] || Thor.new.yes?("#{config.name}: Are you sure you want to destroy the '#{config.name}' VM? [y/N]")
          ports = Yao::Port.list({ device_id: server.id })
          ports.each do |port|
            Yao::Port.destroy(port.id)
            Pec::Logger.notice "port delete id:#{port.id}"
          end if ports

          Yao::Server.destroy(server.id)
          Pec::Logger.info "#{config.name} is deleted!"
        end
      end
    end
  end
end
