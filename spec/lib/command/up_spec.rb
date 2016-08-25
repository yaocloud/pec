require 'spec_helper'
describe Pec::Command::Up do
  before do
    Pec.config_reset

    allow(Pec).to receive(:init_yao).and_return(true)
 
    allow(Yao).to receive(:current_tenant_id).and_return(1)

    allow(Yao::Tenant).to receive(:list).and_return([
      double(id: 1, name: "test_tenant"),
      double(id: 2, name: "include_test_tenant"),
    ])

    allow(Yao::Server).to receive(:list_detail).and_return(servers)

    allow(Yao::Image).to receive(:list).and_return([
      double(id: 1, name: "centos-7.1_chef-12.3_puppet-3.7"),
      double(id: 2, name: "ubuntu-example001")
    ])

    allow(Yao::Flavor).to receive(:list).and_return([
      double(id: 1, name: "m1.small")
    ])

    allow(Yao::SecurityGroup).to receive(:list).and_return([
      double(id: 1, tenant_id: 1, name: 1),
      double(id: 1, tenant_id: 2, name: 1)
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
    subject { described_class.run([]) }
    let(:servers) { [] }

    before do
      allow(Yao::Server).to receive(:create)
    end

    context 'rhel' do
      before do
        allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/redhat_single_instance.yaml"))
      end

      it do
        expect { subject }.not_to raise_error
        expect(Yao::Server).to have_received(:create).with(create_rhel)
      end
    end

    context 'ubuntu' do
      before do
        allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/ubuntu_single_instance.yaml"))
      end

      it do
        expect { subject }.not_to raise_error
        expect(Yao::Server).to have_received(:create).with(create_ubuntu)
      end
    end

    context 'filter' do
      before do
        allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/basic_config.yaml"))
        allow(Pec::Handler::Templates).to receive(:build).and_return({ user_data: YAML.load_file("spec/fixture/user_data_template.yaml") })
      end
      context 'any' do
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).to have_received(:create).with(create_basic_1)
          expect(Yao::Server).to have_received(:create).with(create_basic_2)
        end
      end

      context 'unmatch' do
        subject { described_class.run(["unmatch"]) }
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).not_to have_received(:create)
        end
      end

      context 'single' do
        subject { described_class.run([".*test002"]) }
        it do
          expect { subject }.not_to raise_error
          expect(Yao::Server).not_to have_received(:create).with(create_basic_1)
          expect(Yao::Server).to have_received(:create).with(create_basic_2).once
        end
      end
    end

    context 'recovery' do
      before do
        allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/redhat_single_instance.yaml"))
        allow(Yao::Port).to receive(:destroy)
        allow(Yao::Server).to receive(:create).and_raise("create error")
      end

      it do
        expect { subject }.not_to raise_error
        expect(Yao::Port).to have_received(:destroy).with(1)
      end
    end
  end

  context 'not_created' do
    subject { described_class.run([]) }
    before do
      allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/redhat_single_instance.yaml"))
      allow(Yao::Server).to receive(:create)
      allow(Yao::Server).to receive(:start)
    end

    context 'start' do
      let(:servers) { [double(id: 1, name: "pyama-test001.test.com", status: "SHUTOFF")] }

      it do
        expect { subject }.not_to raise_error
        expect(Yao::Server).not_to have_received(:create)
        expect(Yao::Server).to have_received(:start).with(1).once
      end
    end

    context 'active' do
      let(:servers) { [double(id: 1, name: "pyama-test001.test.com", status: "ACTIVE")] }

      it do
        expect { subject }.not_to raise_error
        expect(Yao::Server).not_to have_received(:create)
        expect(Yao::Server).not_to have_received(:start)
      end
    end
  end
end

def create_rhel
  {
    :name => "pyama-test001.test.com",
    :imageRef => 1,
    :flavorRef => 1,
    :availability_zone => "nova",
    :networks => [{:uuid => '', :port => 1}],
    :user_data =>  "I2Nsb3VkLWNvbmZpZwotLS0KaG9zdG5hbWU6IHB5YW1hLXRlc3QwMDEKdXNl\ncnM6Ci0gbmFtZTogMQpmcWRuOiBweWFtYS10ZXN0MDAxLnRlc3QuY29tCndy\naXRlX2ZpbGVzOgotIGNvbnRlbnQ6IHwKICAgIE5BTUU9ZXRoMAogICAgREVW\nSUNFPWV0aDAKICAgIFRZUEU9RXRoZXJuZXQKICAgIE9OQk9PVD15ZXMKICAg\nIEhXQUREUj0wMDowMDowMDowMDowMDowMAogICAgTkVUTUFTSz0yNTUuMjU1\nLjI1NS4wCiAgICBJUEFERFI9MTAuMTAuMTAuMTAKICAgIEJPT1RQUk9UTz1z\ndGF0aWMKICAgIEdBVEVXQVk9MS4xLjEuMjU0CiAgb3duZXI6IHJvb3Q6cm9v\ndAogIHBhdGg6ICIvZXRjL3N5c2NvbmZpZy9uZXR3b3JrLXNjcmlwdHMvaWZj\nZmctZXRoMCIKICBwZXJtaXNzaW9uczogJzA2NDQnCg==\n",
   :key_name => "example001"
  }
end

def create_ubuntu
  {
    :name => "pyama-test002.test.com",
    :imageRef => 2,
    :flavorRef => 1,
    :availability_zone => "nova",
    :networks => [{:uuid => '', :port => 1}],
    :user_data =>  "I2Nsb3VkLWNvbmZpZwotLS0KaG9zdG5hbWU6IHB5YW1hLXRlc3QwMDEKdXNl\ncnM6Ci0gbmFtZTogMQpmcWRuOiBweWFtYS10ZXN0MDAyLnRlc3QuY29tCndy\naXRlX2ZpbGVzOgotIGNvbnRlbnQ6IHwKICAgIE5BTUU9ZXRoMAogICAgREVW\nSUNFPWV0aDAKICAgIFRZUEU9RXRoZXJuZXQKICAgIE9OQk9PVD15ZXMKICAg\nIEhXQUREUj0wMDowMDowMDowMDowMDowMAogICAgTkVUTUFTSz0yNTUuMjU1\nLjI1NS4wCiAgICBJUEFERFI9MTAuMTAuMTAuMTAKICAgIEJPT1RQUk9UTz1z\ndGF0aWMKICAgIEdBVEVXQVk9MS4xLjEuMjU0CiAgb3duZXI6IHJvb3Q6cm9v\ndAogIHBhdGg6ICIvZXRjL3N5c2NvbmZpZy9uZXR3b3JrLXNjcmlwdHMvaWZj\nZmctZXRoMCIKICBwZXJtaXNzaW9uczogJzA2NDQnCg==\n", :key_name => "example001"
  }
end

def create_basic_1
  {
    :name => "pyama-test001.test.com",
    :imageRef => 1,
    :flavorRef => 1,
    :availability_zone => "nova",
    :networks => [{:uuid => '', :port => 1}],
    :user_data => "I2Nsb3VkLWNvbmZpZwotLS0KdXNlcnM6Ci0gbmFtZTogMgotIG5hbWU6IDEK\naG9zdG5hbWU6IHB5YW1hLXRlc3QwMDEKZnFkbjogcHlhbWEtdGVzdDAwMS50\nZXN0LmNvbQp3cml0ZV9maWxlczoKLSBjb250ZW50OiB8CiAgICBOQU1FPWV0\naDAKICAgIERFVklDRT1ldGgwCiAgICBUWVBFPUV0aGVybmV0CiAgICBPTkJP\nT1Q9eWVzCiAgICBIV0FERFI9MDA6MDA6MDA6MDA6MDA6MDAKICAgIE5FVE1B\nU0s9MjU1LjI1NS4yNTUuMAogICAgSVBBRERSPTEwLjEwLjEwLjEwCiAgICBC\nT09UUFJPVE89c3RhdGljCiAgICBHQVRFV0FZPTEuMS4xLjI1NAogIG93bmVy\nOiByb290OnJvb3QKICBwYXRoOiAiL2V0Yy9zeXNjb25maWcvbmV0d29yay1z\nY3JpcHRzL2lmY2ZnLWV0aDAiCiAgcGVybWlzc2lvbnM6ICcwNjQ0Jwo=\n",
    :key_name => "example001"
  }
end

def create_basic_2
  {
    :name => "pyama-test002.test.com",
    :imageRef => 1,
    :flavorRef => 1,
    :availability_zone => "nova",
    :networks => [{:uuid => '', :port => 1}],
    :user_data => "I2Nsb3VkLWNvbmZpZwotLS0KdXNlcnM6Ci0gbmFtZTogMgotIG5hbWU6IDEK\naG9zdG5hbWU6IHB5YW1hLXRlc3QwMDEKZnFkbjogcHlhbWEtdGVzdDAwMi50\nZXN0LmNvbQp3cml0ZV9maWxlczoKLSBjb250ZW50OiB8CiAgICBOQU1FPWV0\naDAKICAgIERFVklDRT1ldGgwCiAgICBUWVBFPUV0aGVybmV0CiAgICBPTkJP\nT1Q9eWVzCiAgICBIV0FERFI9MDA6MDA6MDA6MDA6MDA6MDAKICAgIE5FVE1B\nU0s9MjU1LjI1NS4yNTUuMAogICAgSVBBRERSPTEwLjEwLjEwLjEwCiAgICBC\nT09UUFJPVE89c3RhdGljCiAgICBHQVRFV0FZPTEuMS4xLjI1NAogIG93bmVy\nOiByb290OnJvb3QKICBwYXRoOiAiL2V0Yy9zeXNjb25maWcvbmV0d29yay1z\nY3JpcHRzL2lmY2ZnLWV0aDAiCiAgcGVybWlzc2lvbnM6ICcwNjQ0Jwo=\n",
    :key_name => "example001"
  }
end
