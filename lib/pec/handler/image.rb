module Pec::Handler
  class Image
    extend Pec::Core
    self.kind = 'image'

    def self.build(host)
      Pec::Logger.notice "image is #{host.image}"
      image_id = Yao::Image.list.find {|image| image.name == host.image}.id
      {
        imageRef:  image_id
      }
    rescue
      raise Pec::ConfigError, "image name=#{host.image} does not exist"
    end
  end
end
