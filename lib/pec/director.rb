module Pec
class Director
    class << self

      def execute(action, host_name, options=nil)
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

        rescue Pec::Errors::Configure => e
          config_load_err_message(e)
        rescue Pec::Errors::Error => e
          err_message(e)
        rescue Errno::ENOENT => e
          err_message(e)
      end

      def assign_director(action, options)
        case
        when action == "make"
          Pec::Director::MakeDirector.new
        when action == "destroy"
          Pec::Director::DestroyDirector.new(options)
        when action == "vm_status"
          Pec::Director::VmStatusDirector.new
        else
          raise
        end
      end

      def err_message(e)
        puts e.to_s.magenta
      end

      def config_load_err_message(e)
        puts e
        puts "can't load configfile".magenta
      end

      def excon_err_message(e)
        if e.response
          JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}".magenta }
        else
          puts e
        end
      end
    end
  end
end
