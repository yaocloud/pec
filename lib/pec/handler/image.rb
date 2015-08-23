module Pec::Handler
  class Image < Base 
    self.kind = 'image'

    def self.build(host)
      Pec::Logger.notice "image is #{host.image}"
      {
        image_ref:  fetch_image(host).id
      }
    end
  end
end
