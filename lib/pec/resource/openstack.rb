module Pec
  class Resource
    class OpenStack
      def initialize(tenant)
        tenant_hash = { openstack_tenant: tenant }
        @network = Fog::Network::OpenStack.new(tenant_hash)
        @compute  = Fog::Compute::OpenStack.new(tenant_hash)
      end

      def port_list
        @_ports ||= @network.list_ports[:body]['ports']
      end

      def subnet_list
        @_subnets ||= @network.list_subnets[:body]['subnets']
      end

      def server_list
        @_servers ||= @compute.list_servers[:body]['servers']
      end

      def security_group_list
        @_security_groups ||= @compute.list_security_groups[:body]['security_groups']
      end

      def image_list
        @_images ||= @compute.list_images[:body]['images']
      end

      def flavor_list
        @_flavors ||= @compute.list_flavors[:body]['flavors']
      end

      def tenant_list
        @_tenants ||= @compute.list_tenants[:body]['tenants']
      end

      def create_server(name, image_ref, flavor_ref, options)
        @compute.create_server(name, image_ref, flavor_ref, options)
      end

      def delete_server(server_id)
        @compute.delete_server(server_id)
      end

      def get_server_details(server_id)
        @compute.get_server_details(server_id)[:body]['server']
      end

      def create_port(network_id, options)
        @network.create_port(network_id, options)
      end

      def delete_port(port_id)
        @network.delete_port(port_id)
      end

    end
  end
end
