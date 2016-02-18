module Pec
  module Command
    autoload :Base,    "pec/command/base"
    autoload :Up,      "pec/command/up"
    autoload :Destroy, "pec/command/destroy"
    autoload :Halt,    "pec/command/halt"
    autoload :Status,  "pec/command/status"
    autoload :Config,  "pec/command/config"
    autoload :Init,    "pec/command/init"
    autoload :List,    "pec/command/list"
    autoload :Hosts,   "pec/command/hosts"
  end
end
