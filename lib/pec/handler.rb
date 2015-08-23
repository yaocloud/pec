module Pec
  module Handler
    autoload :Base,             "pec/handler/base"
    autoload :AvailabilityZone, "pec/handler/availability_zone"
    autoload :Image,            "pec/handler/image"
    autoload :Flavor,           "pec/handler/flavor"
    autoload :Networks,         "pec/handler/networks"
    autoload :UserData,         "pec/handler/user_data"
    autoload :Templates,        "pec/handler/templates"
  end
end
