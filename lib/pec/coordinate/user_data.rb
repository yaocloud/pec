module Pec::Coordinate
  class UserData < Base
    self.kind = 'user_data'
    def build(attribute)
      attribute[:user_data] = Base64.encode64("#cloud-config\n" + attribute[:user_data].to_yaml) if attribute[:user_data]
      attribute
    end
  end
end
