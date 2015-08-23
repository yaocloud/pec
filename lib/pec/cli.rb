require 'pec'
require 'thor'
module Pec
  class CLI < Thor

    desc 'init', 'create sample config'
    def init
      Pec::Init.create_fog_config
      Pec::Init.create_template_dir
      Pec::Init.create_sample_config
    end

    desc 'up', 'create vm by Pec.yaml'
    def up(host_name = nil)
      Pec::Director.make(host_name)
    end

    option :force , type: :boolean, aliases: "-f"
    desc "destroy", "delete vm"
    def destroy(host_name = nil)
      Pec::Director.destroy(host_name, options)
    end

    desc "status", "vm status"
    def status(host_name = nil)
      say("Current machine stasus:", :yellow)
      Pec::Director.status(host_name)
    end
  end
end
