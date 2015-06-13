require 'pec'
require 'thor'
module Pec
  class CLI < Thor

    desc 'init', 'create sample config'
    def init
      dirname = "user_datas"
      unless FileTest.exist?(dirname)
        FileUtils.mkdir_p(dirname) 
        puts "create directry user_datas"
      end
      unless File.exist?("Pec.yaml")
        open("Pec.yaml","w") do |e|
          YAML.dump(Pec::Configure::Sample.pec_file, e)
        end
        puts "create configure file Pec.yaml"
      end
      open("#{dirname}/web_server.yaml.sample","w") do |e|
        YAML.dump(Pec::Configure::Sample.user_data, e)
      end if FileTest.exist?(dirname)

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
