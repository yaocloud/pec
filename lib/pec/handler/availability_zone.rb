module Pec::Handler
  class AvailabilityZone
    extend Pec::Core
    self.kind = 'availability_zone'

    def self.build(config)
      Pec::Logger.notice "availability_zone is #{config.availability_zone}"
      {
        availability_zone: config.availability_zone
      }
    end
  end
end
