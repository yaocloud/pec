module Pec
  class Compute
    class Tenant
      extend Query
      class << self
        def get_name(id)
          begin
            list.find {|p| p["id"] == id }["name"]
          rescue
            Pec::Resource.get_tenant
          end
        end
      end
    end
  end
end
