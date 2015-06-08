module Pec
  module Errors
    class Error < StandardError; end
    class Ethernet < Error; end
    class Subnet < Error; end
    class Port < Error; end
    class Host < Error; end
    class Query < Error; end
    class UserData < Error; end
  end
end
