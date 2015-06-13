module Pec
  class Director
    class DestroyDirector
      def initialize(command_options)
        @command_options = command_options
      end

      def execute!(host)
        compute = Pec::Compute::Server.new
        compute.destroy!(host.name)
      end

      def do_it?(host)
        @command_options[:force] || Thor.new.yes?("#{host.name}: Are you sure you want to destroy the '#{host.name}' VM? [y/N]")
      end

      def err_message(e, host)
          puts e
          puts "can't destroy server:#{host.name}"
      end
    end
  end
end
