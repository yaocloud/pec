module Pec
  class Compute
    class Security_Group
      include Query
      def add_security_group(server_id, security_groups)
        security_groups.each do |sg_name|
          response = Fog::Compute[:openstack].add_security_group(server_id, sg_name)
        end if security_groups
      end
    end
  end
end
