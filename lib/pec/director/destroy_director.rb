module Pec
  class Director
    class DestroyDirector
      def initialize(command_options)
        @command_options = command_options
      end

      def execute!(host)
        Pec::Resource.set_tenant(host.tenant)
        Pec::Compute::Server.destroy!(host.name)
      end

      def do_it?(host)
        @command_options[:force] || Thor.new.yes?("#{host.name}: Are you sure you want to destroy the '#{host.name}' VM? [y/N]")
      end

      def err_message(e, host)
          puts e.to_s.magenta
          puts "can't destroy server:#{host.name}".magenta if host
      end
    end
  end
end
