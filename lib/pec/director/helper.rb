module Pec
  class Director
    class Helper
      class << self

        def set_nics(options, ports)
          ports ? options.merge({ 'nics' =>  ports.map { |port| { port_id: port.id } } }) : options
        end

        def set_availability_zone(options, host)
          host.availability_zone ? options.merge({ 'availability_zone' => host.availability_zone }) : options
        end

      end
    end
  end
end
