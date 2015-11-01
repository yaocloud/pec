require 'spec_helper'
require 'ostruct'
describe Pec::CLI do
  before do
    allow(Pec).to receive(:init_yao).and_return(true)
    allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/load_config_003.yaml"))

    # template
    allow(FileTest).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/user_data_template.yaml"))

    # resource
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
      }),
      OpenStruct.new({
        id: 1,
        name: "include_test_tenant"
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

    allow(Yao::Port).to receive(:get).and_return(
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


    expect(Yao::Server).to receive(:create).with(
      {
        :name=>"pyama-test001.test.com",
        :imageRef=>1,
        :flavorRef=>1,
        :availability_zone=>"nova",
        :networks=>[{:uuid=>nil, :port=>1}],
        :user_data=> "I2Nsb3VkLWNvbmZpZwotLS0KdXNlcnM6Ci0gbmFtZTogMgotIG5hbWU6IDEK\naG9zdG5hbWU6IHB5YW1hLXRlc3QwMDEKZnFkbjogcHlhbWEtdGVzdDAwMS50\nZXN0LmNvbQo6d3JpdGVfZmlsZXM6Ci0gY29udGVudDogfC0KICAgIE5BTUU9\nZXRoMAogICAgREVWSUNFPWV0aDAKICAgIFRZUEU9RXRoZXJuZXQKICAgIE9O\nQk9PVD15ZXMKICAgIEhXQUREUj0wMDowMDowMDowMDowMDowMAogICAgTkVU\nTUFTSz0yNTUuMjU1LjI1NS4wCiAgICBJUEFERFI9MTAuMTAuMTAuMTAKICAg\nIEJPT1RQUk9UTz1zdGF0aWMKICAgIEdBVEVXQVk9MS4xLjEuMjU0CiAgb3du\nZXI6IHJvb3Q6cm9vdAogIHBhdGg6ICIvZXRjL3N5c2NvbmZpZy9uZXR3b3Jr\nLXNjcmlwdHMvaWZjZmctZXRoMCIKICBwZXJtaXNzaW9uczogJzA2NDQnCg==\n",
        :key_name=>"example001"
      }
    )
  end

  subject { described_class.new.invoke(:up , [], nil) }

  it do
    is_expected.to be_truthy
  end
end
