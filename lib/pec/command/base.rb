module Pec::Command
  class Base
    @fetch = false
    def self.run(host_name, options)
      before_do
      Pec.servers(host_name, options, @fetch) do |server,config|
        task(host_name, options, server, config)
      end
      rescue => e
        print_exception(e)
    end

    def self.print_exception(e)
      Pec::Logger.critical(e)
      Pec::Logger.info("\t" + e.backtrace.join("\n\t"))
    end

    def self.task(host_name, options, server, config); end
    def self.before_do; end
  end
end
