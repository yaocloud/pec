module Pec::Handler
  class Image < Base 
    self.kind = 'image'

    def self.build(host)
      Pec::Logger.notice "image is #{host.image}"
      {
        imageRef:  Yao::Image.list.find {|image| image.name == host.image}.id
      }
    end
  end
end
