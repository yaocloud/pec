require 'pec'
require 'thor'
module Pec
  class CLI < Thor

    desc 'init', 'create sample config'
    def init
      dirname = "user_datas"
      FileUtils.mkdir_p(dirname) unless FileTest.exist?(dirname)

      open("Pec.yaml","w") do |e|
        YAML.dump(Pec::Configure::Sample.pec_file, e)
      end unless File.exist?("Pec.yaml")

      open("#{dirname}/web_server.yaml.sample","w") do |e|
        YAML.dump(Pec::Configure::Sample.user_data, e)
      end if FileTest.exist?(dirname)

    end

    option :filename, type: :string, aliases: "-f"
    desc 'up', 'create vm by Pec.yaml'

    def up(host_name = nil)
      config = Pec::Configure.new
      filename = options[:filename] ? options[:filename] : "Pec.yaml"
      config.load(filename)
      director = Pec::VmDirector.new
      config.each do |host|
        next if !host_name.nil? && host.name != host_name
        puts "can't create server:#{host.name}" unless director.make(host)
      end if config
    end
    desc "destroy", "delete vm"
    def destroy(name)
      Pec::Compute::Server.new.destroy!(name) if yes?("#{name}: Are you sure you want to destroy the '#{name}' VM? [y/N]")
    end
  end
end
