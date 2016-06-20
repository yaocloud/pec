require 'pec'
module Pec
  class CLI < Thor
    class_option :config_file , type: :string, aliases: "-c"

    desc 'init', 'create sample config'
    def init
      _sub_command([], options)
    end

    desc 'up [HOSTNAME1, HOSTNAME2, ...]', 'create vm by Pec.yaml'
    def up(*filter_hosts)
      _sub_command(filter_hosts, options)
    end

    option :force , type: :boolean, aliases: "-f"
    desc "destroy [HOSTNAME1, HOSTNAME2, ...]", "delete vm"
    def destroy(*filter_hosts)
      _sub_command(filter_hosts, options)
    end

    desc "halt [HOSTNAME1, HOSTNAME2, ...]", "halt vm"
    def halt(*filter_hosts)
      _sub_command(filter_hosts, options)
    end

    desc "status [HOSTNAME1, HOSTNAME2, ...]", "vm status"
    def status(*filter_hosts)
      _sub_command(filter_hosts, options)
    end

    desc "list", "vm list"
    def list
      _sub_command([], options)
    end

    desc "config [HOSTNAME1, HOSTNAME2, ...]", "show configure"
    def config(*filter_hosts)
      _sub_command(filter_hosts, options)
    end

    desc "hosts", "/etc/hosts records"
    def hosts
      _sub_command([], options)
    end

    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      puts Pec::VERSION
    end

    no_commands do
      def _sub_command(filter_hosts, options)
        Pec.options options
        Object.const_get("Pec::Command::#{caller[0][/`([^']*)'/, 1].capitalize}").run(filter_hosts)
      end
    end
  end
end
