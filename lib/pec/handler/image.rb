module Pec::Handler
  class Image
    extend Pec::Core
    self.kind = 'image'

    def self.build(config)
      Pec::Logger.notice "image is #{config.image}"
      image_id = Yao::Image.list.find {|image| image.name == config.image}.id
      {
        imageRef:  image_id
      }
    rescue
      raise Pec::ConfigError, "image name=#{config.image} does not exist"
    end
  end
end
