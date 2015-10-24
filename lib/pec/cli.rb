require 'pec'
module Pec
  class CLI < Thor

    desc 'init', 'create sample config'
    def init
      _sub_command(host_name, options)
    end

    desc 'up', 'create vm by Pec.yaml'
    def up(host_name = nil)
      _sub_command(host_name, options)
    end

    option :force , type: :boolean, aliases: "-f"
    desc "destroy", "delete vm"
    def destroy(host_name = nil)
      _sub_command(host_name, options)
    end

    desc "status", "vm status"
    def status(host_name = nil)
      _sub_command(host_name, options)
    end

    desc "list", "vm list"
    def list(host_name = nil)
      _sub_command(host_name, options)
    end

    desc "config", "show configure"
    def config
      _sub_command(host_name, options)
    end

    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      puts Pec::VERSION
    end

    no_commands do
      def _sub_command(host_name, options)
        Object.const_get("Pec::Command::#{caller[0][/`([^']*)'/, 1].capitalize}").run(host_name, options)
      end
    end
  end
end
