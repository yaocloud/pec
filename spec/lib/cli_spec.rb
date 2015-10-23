require 'spec_helper'
require 'ostruct'
describe Pec::CLI do
  before do
    allow(Pec).to receive(:init_yao).and_return(true)
    allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/load_config_001.yaml"))

    # template
    allow(FileTest).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/user_data_template.yaml"))

    # resource
    allow(Yao::Server).to receive(:create).and_return(true)
    allow(Yao::Server).to receive(:list_detail).and_return([
      OpenStruct.new({
        id: 1,
        name: 1
      })
    ])

    allow(Yao::Tenant).to receive(:list).and_return([
      OpenStruct.new({
        id: 1,
        name: "test_tenant"
      })
    ])

    allow(Yao::Image).to receive(:list).and_return([
      OpenStruct.new({
        id: 1,
        name: "centos-7.1_chef-12.3_puppet-3.7"
      })
    ])
    allow(Yao::Flavor).to receive(:list).and_return([
      OpenStruct.new({
        id: 1,
        name: "m1.small"
      })
    ])
    allow(Yao::SecurityGroup).to receive(:list).and_return([
      OpenStruct.new({
        id: 1,
        tenant_id: 1,
        name: 1
      })
    ])

    allow(Yao::Subnet).to receive(:list).and_return([
      OpenStruct.new({
        id: 1,
        network_id: 1,
        cidr: "1.1.1.0/24",
      })
    ])

    allow(Yao::Port).to receive(:create).and_return(
      OpenStruct.new({
        id: 1,
        name: "eth0",
        mac_address: '00:00:00:00:00:00',
        fixed_ips: [
          {
            'ip_address' => "10.10.10.10"
          }
        ]
      })
    )

    allow(Yao::Keypair).to receive(:list).and_return([
      OpenStruct.new({
        id: 1,
        name: "example001"
      })
    ])
  end

  subject { described_class.new.invoke(:up , [], nil) }

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
    is_expected.to be_truthy
  end
end
