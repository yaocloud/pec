module Pec
  class Resource
    class Mock
      def initialize(tenant)
        tenant_hash = { "openstack_tenant" => tenant }
      end

      def port_list
        1.upto(10).map do |c|
          {
            "id" => c,
            "fixed_ips" => [
              { "subnet_id" => c,
                "ip_address" => "#{c}." * 3 + "#{c}"
              }
            ],
            "network_id" => c,
            "device_owner" => c % 2 == 0 ? c.to_s : "",
            "admin_state_up" => c % 2 == 0 ? "True" : "False"
          }
       end
      end

      def subnet_list
        1.upto(10).map do |c|
          {
            "id" => c,
            "cidr" => "#{c}." * 3 + "0/24",
            "network_id" => c
          }
        end
      end

      def server_list
        10.upto(20).map do |c|
          {
            "id" => c,
            "name" => c,
            "status" => c %2 == 0 ? "Active" : "SHUTOFF"
          }
        end
      end

      def security_group_list
        1.upto(10).map do |c|
          {
            "id" => c,
            "name" => c
          }
        end
      end

      def image_list
        1.upto(10).map do |c|
          {
            "id" => c,
            "name" => c,
            "links" => [
              "href" => c
            ]
          }
        end
      end

      def flavor_list
        1.upto(10).map do |c|
          {
            "id" => c,
            "name" => c,
            "links" => [
              "href" => c
            ]
          }
        end
      end

      def tenant_list
        1.upto(10).map do |c|
          {
            "id" => c,
            "name" => c
          }
        end
      end

      def create_server(name, image_ref, flavor_ref, options)
        object = Object.new
        object.set_value(name, 202)
        object
      end

      def delete_server(server_id)
        object = Object.new
        object.set_value(server_id, 204)
        object
      end

      def get_server_details(server_id)
        if server_id.to_i % 2 == 0
          {
            "status" => "active",
            "OS-EXT-SRV-ATTR:host" => "#{server_id}.compute.node",
            "flavor" => {
              "id" => server_id
            },
            "tenant_id" => server_id,
            "addresses" => {
              "test_net" => [
                "addr" => server_id
              ]
            }
          }
        else
          {
            "status" => "uncreated",
            "OS-EXT-SRV-ATTR:host" => "#{server_id}.compute.node",
            "flavor" => {
              "id" => server_id
            },
            "tenant_id" => server_id,
            "addresses" => {
              "test_net" => {
                "addr" => server_id
              }
            }
          }
        end
      end
      def create_port(network_id, options)
        object = Object.new
        object.set_value(network_id, 201)
        object
      end

      def delete_port(port_id)
        object = Object.new
        object.set_value(port_id, 204)
        object
      end
    end
  end
end
class Object
  attr_reader :status
  def set_value(value, status)
    @value = value
    @status = @value.to_i % 2 == 0 ? 999 : status
  end

  def [](key)
    @status
  end

  def data
    {
      :body => {
        "port" => {
          "id" => @value,
          "fixed_ips" => [
            { 
              "subnet_id" => @value,
              "ip_address" => "#{@value}." * 3 + "#{@value}"
            }
          ],
          "network_id" => @value,
          "device_owner" => @value.to_i % 2 == 0 ? @value : "",
          "admin_state_up" => @value.to_i % 2 == 0 ? "True" : "False"
        },
        "server" => {
          "id" => @value
        }
      }
    }
  end
end
