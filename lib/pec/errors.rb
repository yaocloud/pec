module Pec
  module Errors
    class Error < StandardError; end
    class Ethernet < Error; end
    class Subnet < Error; end
    class Port < Error; end
    class Host < Error; end
    class Query < Error; end
    class UserData < Error; end
    class Configure < Error; end
    class SecurityGroup < Error; end
  end
end
