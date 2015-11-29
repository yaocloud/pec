module Pec::Command
  class Base
    def self.run(filter_hosts, options)
      before_do
      Pec.servers(filter_hosts, options, not_fetch) do |server,config|
        task(options, server, config)
      end
      after_do
      rescue => e
        print_exception(e)
    end

    def self.print_exception(e)
      Pec::Logger.critical(e)
      Pec::Logger.info("\t" + e.backtrace.join("\n\t"))
    end

    def self.not_fetch; end
    def self.task(options, server, config); end
    def self.before_do; end
    def self.after_do; end

  end
end
