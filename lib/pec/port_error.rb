class Pec::PortError < StandardError
  attr_accessor :attribute
  def initialize(ports)
    self.attribute = {
      networks: ports.map {|port| { uuid: '', port: port.id }}
    } if ports
  end
end
