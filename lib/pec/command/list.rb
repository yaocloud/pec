module Pec::Command
  class List < Base
    def self.task(server, config)
      puts sprintf(
        " %-35s",
        config.name
      )
    end

    def self.before_do
      Thor.new.say("vm list:", :yellow)
    end

    def self.not_fetch
      true
    end
  end
end
