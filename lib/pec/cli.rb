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
      Pec::Director.execute("make", host_name, options)
    end

    option :force , type: :boolean, aliases: "-f"
    desc "destroy", "delete vm"
    def destroy(host_name = nil)
      Pec::Director.execute("destroy", host_name, options)
    end
  end
end
