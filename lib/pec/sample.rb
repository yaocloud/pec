module Pec
  class Configure
    class Sample
      class << self
        def pec_file
          {
            "your_sever_name" => {
              "tenant" =>  "your_tenant",
              "image" =>  "centos-7",
              "flavor" =>  "m1.small",
              "allowed_address_pairs" => "nova",
              "networks" => {
                "eth0" => {
                  "bootproto" => "static",
                  "ip_address" => "10.0.0.0/24",
                  "allowed_address_pairs" => ["10.0.0.1"],
                  "gateway" =>  "10.0.0.254",
                  "dns1" => "10.0.0.10"
                },
                "eth1" => {
                  "bootproto" => "static",
                  "ip_address" => "20.0.0.11/24",
                  "gateway" =>  "20.0.0.254",
                  "dns1" => "20.0.0.10"
                }
              },
              "security_group" => [
                "default",
                "www_from_any"
              ],
              "templates" => [
                "web_server.yaml"
              ],
              "user_data" => {
                  "hostname" => "pec",
                  "fqdn" => "pec.pyama.com"
               }
            }
          }
        end

        def user_data
          {
            "hostname" => "pec",
            "fqdn" => "pec.pyama.com",
            "users" => [
              {
                "name" => "centos",
                "groups" => "sudo",
                "shell" => "/bin/sh"
              }
            ]
          }
        end
      end
    end
  end
end
