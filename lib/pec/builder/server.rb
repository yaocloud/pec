module Pec
  module Builder
    class Server
      def build(host)
        Pec::Logger.notice "flavor is #{host.flavor}"
        Pec::Logger.notice "image is #{host.image}"
        hash = {
          name: host.name,
          flavor_ref: fetch_flavor(host).id,
          image_ref:  fetch_image(host).id
        }
        hash[:availability_zone] = host.availability_zone if host.availability_zone
        hash
      end
      
      def self.resource(name)
        define_method("fetch_#{name}", -> (host) {
          r = Pec.compute.send("#{name}s").find {|val|val.name == host.send(name)}
          raise "not fond #{name} #{host.send(name)}" unless r
          r
        })
      end

      resource 'flavor'
      resource 'image'
    end
  end
end
