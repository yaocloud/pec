module Pec::Command
  class List < Base
    def self.run(host_name, options)
      Thor.new.say("vm list:", :yellow)
      Pec.configure.each do |host|
        puts sprintf(
          " %-35s",
          host.name,
        )
      end
    end
  end
end
