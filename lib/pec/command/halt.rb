module Pec::Command
  class Halt < Base
    @fetch = true
    def self.task(host_name, options, server, config)
      case
      when server.nil?
        Pec::Logger.notice "not be created #{config.name}"
      when server.status != "ACTIVE"
        Pec::Logger.notice "#{config.name} server status is #{server.status} must be ACTIVE"
      else
        Yao::Server.shutoff(server.id)
        Pec::Logger.info "#{config.name} is halted!"
      end
    end
  end
end
