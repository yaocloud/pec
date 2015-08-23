module Pec::Handler
  class Base
    class << self
      attr_accessor :kind

      %w(image flavor).each do |name|
        define_method("fetch_#{name}", -> (host) {
          unless resource = Pec.compute.send("#{name}s").find {|val|val.name == host.send(name)}
            raise "not fond #{name} #{host.send(name)}"
          end
          resource
        })
      end
    end
  end
end
