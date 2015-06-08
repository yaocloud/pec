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

    desc 'up', 'create vm by Pec.yaml'
    def up(host_name = nil)
      config = Pec::Configure.new
      config.load("Pec.yaml")

      director = Pec::VmDirector.new
      config.each do |host|
        next if !host_name.nil? && host.name != host_name

        begin
          director.make(host)
        rescue Pec::Errors::Error => e
          puts e
          puts "can't create server:#{host.name}"
        rescue Excon::Errors::Error => e
          JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
        end
      end if config
    end

    option :force , type: :boolean, aliases: "-f"
    desc "destroy", "delete vm"
    def destroy(name = nil)
      config = Pec::Configure.new
      config.load("Pec.yaml")

      config.each do |host|
        next if !name.nil? && host.name != name
        begin
          Pec::Compute::Server.new.destroy!(host.name) if yes?("#{host.name}: Are you sure you want to destroy the '#{host.name}' VM? [y/N]") || options["force"]
        rescue Pec::Errors::Error => e
          puts e
          puts "can't create server:#{host.name}"
        rescue Excon::Errors::Error => e
          JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
        end
      end if config
    end
  end
end
