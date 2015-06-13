module Pec
class Director
    class << self
      def execute(action, host_name, options)
        config = Pec::Configure.new("Pec.yaml")
        director = assign_director(action, options)
        config.filter_by_host(host_name).each do |host|
          begin
            director.execute!(host) if director.do_it?(host)
          rescue Pec::Errors::Error => e
            director.err_message(e, host)
          rescue Excon::Errors::Error => e
            excon_err_message(e)
          end
        end if config

        rescue Errno::ENOENT => e
          err_messag(e)
        rescue Pec::Errors::Configure => e
          config_load_err_message
      end

      def assign_director(action, options)
        case
        when action == "make"
          Pec::Director::MakeDirector.new(options)
        when action == "destroy"
          Pec::Director::DestroyDirector.new(options)
        else
          raise
        end
      end


      def err_message(e)
        puts e
      end

      def config_load_err_message
        puts "configure can't load"
      end

      def excon_err_message(e)
          JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
      end
    end
  end
end
