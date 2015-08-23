module Pec::Handler
  class Base
    class << self
      attr_accessor :kind

      %w(image flavor).each do |name|
        define_method("fetch_#{name}", -> (host) {
          r = Pec.compute.send("#{name}s").find {|val|val.name == host.send(name)}
          raise "not fond #{name} #{host.send(name)}" unless r
          r
        })
      end
    end
  end
end
