module Pec
  class Init
    class << self
      def create_template_dir
        dirname = "user_data"
        unless FileTest.exist?(dirname)
          FileUtils.mkdir_p(dirname)
          open("#{dirname}/web_server.yaml.sample","w") do |e|
            YAML.dump(Pec::Configure::Sample.user_data, e)
          end if FileTest.exist?(dirname)
          puts "create directry user_data".green
        end
      end

      def create_sample_config
        unless File.exist?("Pec.yaml")
          open("Pec.yaml","w") do |e|
            YAML.dump(Pec::Configure::Sample.pec_file, e)
          end
          puts "create configure file Pec.yaml".green
        end
      end

      def show_env_setting
          thor = Thor.new
          thor.say("please set env this paramater", :yellow)
          puts " export OS_AUTH_URL=http://your_keystone_server:port/v2.0"
          puts " export OS_USERNAME=your name"
          puts " export OS_PASSWORD=your password"
      end
    end
  end
end
