module Pec::Command
  class Destroy < Base
    def self.task(host_name, options, server, config)
      unless server
        Pec::Logger.notice "not be created #{config.name}"
      else
        if options[:force] || Thor.new.yes?("#{config.name}: Are you sure you want to destroy the '#{config.name}' VM? [y/N]")
          Yao::Server.destroy(server.id)
          Pec::Logger.info "#{config.name} is deleted!"
        end
      end
    end
  end
end
