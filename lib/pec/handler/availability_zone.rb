module Pec::Handler
  class AvailabilityZone < Base 
    self.kind = 'availability_zone'

    def self.build(host)
      Pec::Logger.notice "availability_zone is #{host.availability_zone}"
      {
        availability_zone: host.availability_zone
      }
    end
  end
end
