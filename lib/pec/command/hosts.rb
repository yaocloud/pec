require 'ipaddr'
module Pec::Command
  class Hosts < Base
    def self.task(server, config)
      ip_addresses(server).each do |i|
        host_name = private_ip?(i) ? "#{config.name}.lan" : config.name
        puts sprintf(
          "%-15s %-35s",
          i,
          host_name,
        )
      end if server
    end

    def self.ip_addresses(server)
      server.addresses.map do |ethers|
        ethers[1].map do |ether|
          ether["addr"]
        end
      end.flatten
    end

    def self.private_ip?(target)
      ::IPAddr.new("10.0.0.0/8").include?(target) ||
      ::IPAddr.new("172.16.0.0/12").include?(target) ||
      ::IPAddr.new("192.168.0.0/16").include?(target)
    end

    def self.before_do
      @_error = nil
      Pec::Logger.warning "------ #{Date.today.strftime("%Y%m%d%H%M%S")} pec add start ------"
    end

    def self.after_do
      m = ("-" * 16)
      n = ("-" * 17)
      Pec::Logger.warning  m + " pec end " + n
    end
  end
end
