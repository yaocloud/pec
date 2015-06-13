module Pec
  class Init
    class << self
      def create_template_dir
        dirname = "user_datas"
        unless FileTest.exist?(dirname)
          FileUtils.mkdir_p(dirname) 
          open("#{dirname}/web_server.yaml.sample","w") do |e|
            YAML.dump(Pec::Configure::Sample.user_data, e)
          end if FileTest.exist?(dirname)
          puts "create directry user_datas"
        end
      end

      def create_sample_config
        unless File.exist?("Pec.yaml")
          open("Pec.yaml","w") do |e|
            YAML.dump(Pec::Configure::Sample.pec_file, e)
          end
          puts "create configure file Pec.yaml"
        end
      end

      def create_fog_config
        thor = Thor.new
        if !File.exist?(File.expand_path("~/.fog")) || thor.yes?("Do you want to overwrite the existing ~/.fog? [y/N]") 
          thor.say("Start Configure by OpenStack", :yellow)
          params = {}

          params = %w(auth_uri username api_key tenant).inject({}) do |user_input, c|
            user_input["openstack_#{c}"] = thor.ask("openstack #{c}:")
            user_input
          end

          thor.say("Configure Complete!", :blue) if open(File.expand_path("~/.fog"), "w") do |e|
            YAML.dump({ "default" => params }, e)
          end
        end
      end
    end
  end
end
