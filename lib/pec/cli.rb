require 'pec'
module Pec
  class CLI < Thor

    desc 'init', 'create sample config'
    def init(hosts=nil)
      _sub_command(hosts, options)
    end

    desc 'up', 'create vm by Pec.yaml'
    def up(hosts = nil)
      _sub_command(hosts, options)
    end

    option :force , type: :boolean, aliases: "-f"
    desc "destroy", "delete vm"
    def destroy(hosts = nil)
      _sub_command(hosts, options)
    end

    desc "status", "vm status"
    def status(hosts = nil)
      _sub_command(hosts, options)
    end

    desc "list", "vm list"
    def list(hosts = nil)
      _sub_command(hosts, options)
    end

    desc "config", "show configure"
    def config(hosts=nil)
      _sub_command(hosts, options)
    end

    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      puts Pec::VERSION
    end

    no_commands do
      def _sub_command(hosts, options)
        Object.const_get("Pec::Command::#{caller[0][/`([^']*)'/, 1].capitalize}").run(hosts, options)
      end
    end
  end
end
