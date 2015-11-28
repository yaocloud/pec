require 'spec_helper'
require 'ostruct'
describe Pec::Command::Up do
  before do
    Pec.config_reset

    allow(Pec).to receive(:init_yao).and_return(true)

    allow(Yao::Server).to receive(:list_detail).and_return([])

    allow(Yao::Tenant).to receive(:list).and_return([
      double(id: 1, name: "test_tenant"),
      double(id: 2, name: "include_test_tenant"),
    ])

    allow(Yao::Image).to receive(:list).and_return([
      double(id: 1, name: "centos-7.1_chef-12.3_puppet-3.7"),
      double(id: 2, name: "ubuntu-example001")
    ])

    allow(Yao::Flavor).to receive(:list).and_return([
      double(id: 1, name: "m1.small")
    ])

    allow(Yao::SecurityGroup).to receive(:list).and_return([
      double(id: 1, tenant_id: 1, name: 1)
    ])

    allow(Yao::Subnet).to receive(:list).and_return([
      double(id: 1, network_id: 1, cidr: "1.1.1.0/24")
    ])

    allow(Yao::Port).to receive(:create).and_return(
      double(id: 1, name: "eth0", mac_address: '00:00:00:00:00:00', fixed_ips: [ { 'ip_address' => "10.10.10.10" } ])
    )

    allow(Yao::Port).to receive(:get).and_return(
      double(id: 1, name: "eth0", mac_address: '00:00:00:00:00:00', fixed_ips: [ { 'ip_address' => "10.10.10.10" } ])
    )

    allow(Yao::Keypair).to receive(:list).and_return([
      double(id: 1, name: "example001")
    ])
  end

  context 'create_instance' do
    subject { described_class.run([], nil) }

    before do
      allow(Yao::Server).to receive(:create)
    end

    context 'rhel' do
      before do
        allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/redhat_single_instance.yaml"))
      end

      it do
        is_expected.to be_truthy
        expect(Yao::Server).to have_received(:create).with(
          create_rhel
        )
      end
    end

    context 'ubuntu' do
      before do
        allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/ubuntu_single_instance.yaml"))
      end

      it do
        is_expected.to be_truthy
        expect(Yao::Server).to have_received(:create).with(
          create_ubuntu
        )
      end
    end
  end

  context 'recovery' do
    subject { described_class.run([], nil) }

    before do
      allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/redhat_single_instance.yaml"))
      allow(Yao::Port).to receive(:destroy)
      RSpec::Mocks.space.proxy_for(Yao::Server).reset
      allow(Yao::Server).to receive(:create).and_raise("create error")
    end

    it do
      is_expected.to be_truthy
      expect(Yao::Port).to have_received(:destroy).with(1)
    end
  end
end

def create_rhel
  {
    :name => "pyama-test001.test.com",
    :imageRef => 1,
    :flavorRef => 1,
    :availability_zone => "nova",
    :networks => [{:uuid => nil, :port => 1}],
    :user_data =>  "I2Nsb3VkLWNvbmZpZwotLS0KaG9zdG5hbWU6IHB5YW1hLXRlc3QwMDEKdXNl\ncnM6Ci0gbmFtZTogMQpmcWRuOiBweWFtYS10ZXN0MDAxLnRlc3QuY29tCndy\naXRlX2ZpbGVzOgotIGNvbnRlbnQ6IHwtCiAgICBOQU1FPWV0aDAKICAgIERF\nVklDRT1ldGgwCiAgICBUWVBFPUV0aGVybmV0CiAgICBPTkJPT1Q9eWVzCiAg\nICBIV0FERFI9MDA6MDA6MDA6MDA6MDA6MDAKICAgIE5FVE1BU0s9MjU1LjI1\nNS4yNTUuMAogICAgSVBBRERSPTEwLjEwLjEwLjEwCiAgICBCT09UUFJPVE89\nc3RhdGljCiAgICBHQVRFV0FZPTEuMS4xLjI1NAogIG93bmVyOiByb290OnJv\nb3QKICBwYXRoOiAiL2V0Yy9zeXNjb25maWcvbmV0d29yay1zY3JpcHRzL2lm\nY2ZnLWV0aDAiCiAgcGVybWlzc2lvbnM6ICcwNjQ0Jwo=\n",
   :key_name => "example001"
  }
end

def create_ubuntu
  {
    :name => "pyama-test002.test.com",
    :imageRef => 2,
    :flavorRef => 1,
    :availability_zone => "nova",
    :networks => [{:uuid => nil, :port => 1}],
    :user_data =>  "I2Nsb3VkLWNvbmZpZwotLS0KaG9zdG5hbWU6IHB5YW1hLXRlc3QwMDEKdXNl\ncnM6Ci0gbmFtZTogMQpmcWRuOiBweWFtYS10ZXN0MDAyLnRlc3QuY29tCndy\naXRlX2ZpbGVzOgotIGNvbnRlbnQ6IHwtCiAgICBOQU1FPWV0aDAKICAgIERF\nVklDRT1ldGgwCiAgICBUWVBFPUV0aGVybmV0CiAgICBPTkJPT1Q9eWVzCiAg\nICBIV0FERFI9MDA6MDA6MDA6MDA6MDA6MDAKICAgIE5FVE1BU0s9MjU1LjI1\nNS4yNTUuMAogICAgSVBBRERSPTEwLjEwLjEwLjEwCiAgICBCT09UUFJPVE89\nc3RhdGljCiAgICBHQVRFV0FZPTEuMS4xLjI1NAogIG93bmVyOiByb290OnJv\nb3QKICBwYXRoOiAiL2V0Yy9zeXNjb25maWcvbmV0d29yay1zY3JpcHRzL2lm\nY2ZnLWV0aDAiCiAgcGVybWlzc2lvbnM6ICcwNjQ0Jwo=\n", :key_name => "example001"
  }
end
