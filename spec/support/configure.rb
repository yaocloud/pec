def get_delete_column_hash(column)
  hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
  hash["pyama-test001.test.com"].delete(column)
  hash
end

def get_nil_column_hash(column)
  hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
  hash["pyama-test001.test.com"][column] = nil
  hash
end

def set_network_bootproto(value)
  hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
  hash["pyama-test001.test.com"]["networks"]["eth0"]["bootproto"] = value
  hash
end

def get_delete_network_column_hash(column)
  hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
  hash["pyama-test001.test.com"]["networks"]["eth0"].delete("ip_address")
  hash
end

def get_ether_static_config
  [
    'eth0',
    {
      'bootproto' => 'static',
      'ip_address' => '1.1.1.1/24' 
    }
  ]
end

def get_ether_dhcp_config
  [
    'eth0',
    {
      'bootproto' => 'static',
      'ip_address' => '1.1.1.0/24',
      'allowed_address_pairs' => [
        {
          'ip_address' => '1.1.1.10/24'
        }
      ]
    }
  ]
end

def get_ether_use_static_config
  [
    'eth0',
    {
      'bootproto' => 'static',
      'ip_address' => '2.2.2.2/24' 
    }
  ]
end
