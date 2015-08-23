require 'spec_helper'
require 'ostruct'
describe Pec::Director do
  before do
    allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/load_config_001.yaml"))
    allow(Pec).to receive(:compute).and_return(OpenStruct.new())
    allow(Pec).to receive(:neutron).and_return(OpenStruct.new())
    allow_any_instance_of(OpenStruct).to receive(:set_tenant).and_return(OpenStruct.new())
    allow_any_instance_of(OpenStruct).to receive(:set_tenant_patch).and_return(OpenStruct.new())
    allow_any_instance_of(OpenStruct).to receive(:servers).and_return(OpenStruct.new())
    
    allow_any_instance_of(Fog::Compute::OpenStack::Real).to receive(:set_tenant).and_return(true)
    allow_any_instance_of(Fog::Network::OpenStack::Real).to receive(:set_tenant_patch).and_return(true)
    # template 
    allow(FileTest).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/user_data_template.yaml"))

    allow(Pec::Handler::Image).to receive(:fetch_image).and_return(OpenStruct.new({id: 1}))
    allow(Pec::Handler::Flavor).to receive(:fetch_flavor).and_return(OpenStruct.new({id: 1}))
    allow(Pec::Handler::Networks).to receive(:create_port).and_return(OpenStruct.new({
      id: 1,
      name: "eth0",
      mac_address: '00:00:00:00:00:00',
      fixed_ips: [
        {
          'ip_address' => "10.10.10.10/24"
        }
      ]
    }))
  end
  subject { described_class.make(nil) }
  it do
    allow_any_instance_of(OpenStruct).to receive(:create).with(
      {
        :name => "pyama-test001.test.com",
        :image_ref => 1,
        :flavor_ref => 1,
        :availability_zone => "nova",
        :nics => [
          {:port_id => 1}
        ],
        :user_data => 
        "#cloud-config\n---\nwrite_files:\n- content: |-\n    NAME=eth0\n    DEVICE=eth0\n    TYPE=Ethernet\n    ONBOOT=yes\n    HWADDR=00:00:00:00:00:00\n    NETMASK=255.255.255.0\n    IPADDR=10.10.10.10\n    BOOTPROTO=static\n    GATEWAY=1.1.1.254\n  owner: root:root\n  path: \"/etc/sysconfig/network-scripts/ifcfg-eth0\"\n  permissions: '0644'\nusers:\n- name: 2\n- name: 1\nhostname: pyama-test001\nfqdn: pyama-test001.test.com\n"
      }
    )
    is_expected.to be_instance_of(Array)
  end
end