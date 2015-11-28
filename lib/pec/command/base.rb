module Pec::Command
  class Base
    def self.run(host_name, options)
      before_do
      Pec.servers(host_name, options, not_fetch) do |server,config|
        task(host_name, options, server, config)
      end
      rescue => e
        print_exception(e)
    end

    def self.print_exception(e)
      Pec::Logger.critical(e)
      Pec::Logger.info("\t" + e.backtrace.join("\n\t"))
    end

    def self.not_fetch; end
    def self.task(host_name, options, server, config); end
    def self.before_do; end

  end
end
