require 'spec_helper'
describe Pec::Command::Status do
  before do
    Pec.config_reset

    allow(Pec).to receive(:init_yao).and_return(true)

    allow(Yao::Tenant).to receive(:list).and_return(tenant)

    allow(Yao::Server).to receive(:list_detail).and_return(
      [
        double(
          id: 1,
          tenant_id: 1,
          flavor: { "id" => 1 },
          name: "pyama-test001.test.com",
          status: "ACTIVE",
          availability_zone: "az1",
          key_name: "key1",
          ext_srv_attr_host: "compute1",
          addresses: [
            [
              "if",
              [
                { "addr" => "1.1.1.1" }
              ]
            ]
          ]
        ),
        double(
          id: 2,
          tenant_id: 2,
          flavor: { "id" => 2 },
          name: "pyama-test002.test.com",
          status: "ACTIVE",
          availability_zone: "az2",
          key_name: "key2",
          ext_srv_attr_host: "compute2",
          addresses: [
            [
              "if",
              [
                { "addr" => "2.2.2.2" },
                { "addr" => "3.3.3.3" }
              ]
            ]
          ]
        )
      ]
    )

    allow(Yao::Image).to receive(:list).and_return([
      double(id: 1, name: "centos-7.1_chef-12.3_puppet-3.7"),
      double(id: 2, name: "ubuntu-example001")
    ])

    allow(Yao::Flavor).to receive(:list).and_return(
      flavor
    )

    allow(Yao::Port).to receive(:get).and_return(
      double(id: 1, name: "eth0", mac_address: '00:00:00:00:00:00', fixed_ips: [ { 'ip_address' => "10.10.10.10" } ])
    )

  end

  context 'show_instance' do
    subject { described_class.run([]) }

    let(:tenant) {[
      double(id: 1, name: "test_tenant"),
      double(id: 2, name: "include_test_tenant"),
    ]}

    let(:flavor) {[
      double(id: 1, name: "m1.small"),
      double(id: 2, name: "m2.small")
    ]}


    before do
      allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/basic_config.yaml"))
      allow(Pec::Handler::Templates).to receive(:build).and_return({ user_data: YAML.load_file("spec/fixture/user_data_template.yaml") })
    end

    context 'filter' do
      context 'any' do
        it do
          expect { subject }.to output(print_any).to_stdout
        end
      end

      context 'unmatch' do
        subject { described_class.run(["unmatch"]) }
        it do
          expect { subject }.to output(print_unmatch).to_stdout
        end
      end

      context 'single' do
        subject { described_class.run([".*test002"]) }
        it do
          expect { subject }.to output(print_single).to_stdout
        end
      end
    end

    context 'delete_resource' do
      context 'flavor' do
        let(:flavor) {[
          double(id: 1, name: "m1.small")
        ]}
        it do
          expect { subject }.to output(print_delete_flavor).to_stdout
        end
      end
    end
  end
end

def print_any
<<-EOS
\e[33mCurrent machine status:\e[0m
 pyama-test001.test.com              ACTIVE     test_tenant m1.small   az1        key1       compute1                            1.1.1.1                                         
 pyama-test002.test.com              ACTIVE     include_test_tenant m2.small   az2        key2       compute2                            2.2.2.2,3.3.3.3                                 
EOS
end

def print_unmatch
<<-EOS
\e[33mCurrent machine status:\e[0m
EOS
end

def print_single
<<-EOS
\e[33mCurrent machine status:\e[0m
 pyama-test002.test.com              ACTIVE     include_test_tenant m2.small   az2        key2       compute2                            2.2.2.2,3.3.3.3                                 
EOS
end

def print_delete_flavor
<<-EOS
\e[33mCurrent machine status:\e[0m
 pyama-test001.test.com              ACTIVE     test_tenant m1.small   az1        key1       compute1                            1.1.1.1                                         
 pyama-test002.test.com              ACTIVE     include_test_tenant m1.small   az2        key2       compute2                            2.2.2.2,3.3.3.3                                 
\e[33mpyama-test002.test.com:flavor is unmatch id. may be id has changed\e[0m
EOS
end
