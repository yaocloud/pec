module Pec
  class Compute
    class Tenant
      extend Query
      class << self
        def get_name(id)
          list.find {|p| p["id"] == id }["name"]
        end
      end
    end
  end
end
