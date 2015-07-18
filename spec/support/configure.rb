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

def get_array_column_to_string_hash(column)
  hash =  YAML.load_file("spec/fixture/in/pec_configure_p1.yaml")
  hash["pyama-test001.test.com"][column] = column
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
