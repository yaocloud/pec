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

      def fetch_image(host)
        Pec.compute.images.find {|image|image.name == host.image}
      end

      def fetch_flavor(host)
        Pec.compute.flavors.find {|flavor|flavor.name == host.flavor}
      end
    end
  end
end
