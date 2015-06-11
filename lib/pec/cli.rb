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
      config = Pec::Configure.new("Pec.yaml")
      director = Pec::VmDirector.new

      config.filter_by_host(host_name).each do |host|
        begin
          director.make(host)
        rescue Pec::Errors::Error => e
          puts e
          puts "can't create server:#{host.name}"
        rescue Excon::Errors::Error => e
          JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
        end
      end if config
      rescue Errno::ENOENT => e
        puts e
      rescue Pec::Errors::Configure => e
        puts "configure can't load"
    end

    option :force , type: :boolean, aliases: "-f"
    desc "destroy", "delete vm"
    def destroy(host_name = nil)
      config = Pec::Configure.new("Pec.yaml")
      config.filter_by_host(host_name).each do |host|
        begin
          Pec::Compute::Server.new.destroy!(host.name) if options[:force] || yes?("#{host.name}: Are you sure you want to destroy the '#{host.name}' VM? [y/N]")
        rescue Pec::Errors::Error => e
          puts e
          puts "can't create server:#{host.name}"
        end
      end if config
      rescue Errno::ENOENT => e
        puts e
    end
  end
end
