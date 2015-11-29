require 'spec_helper'
describe Pec::Command::Config do
  subject { described_class.run([]) }

  before do
    Pec.config_reset
    allow(Pec).to receive(:init_yao).and_return(true)
    allow(Pec::Handler::Templates).to receive(:build).and_return({ user_data: YAML.load_file("spec/fixture/user_data_template.yaml") })
  end

  context 'yaml' do
    before do
      allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/basic_config.yaml"))
    end

    it do
     expect { subject }.to output(print_yaml).to_stdout
    end
  end

  context 'erb' do
    before do
      allow(Pec).to receive(:load_config).and_return(Pec.load_config("spec/fixture/erb_basic_config.yaml.erb"))
    end

    it do
      expect { subject }.to output(print_yaml).to_stdout
    end
  end
end

def print_yaml
<<-EOS
---
pyama-test001.test.com:
  image: centos-7.1_chef-12.3_puppet-3.7
  flavor: m1.small
  availability_zone: nova
  tenant: test_tenant
  security_group:
  - 1
  networks:
    eth0:
      allowed_address_pairs:
      - 10.2.0.0
      bootproto: static
      ip_address: 1.1.1.1/24
      gateway: 1.1.1.254
  templates:
  - user_data_template
  user_data:
    hostname: pyama-test001
    users:
    - name: 1
  keypair: example001
---
pyama-test002.test.com:
  image: centos-7.1_chef-12.3_puppet-3.7
  flavor: m1.small
  availability_zone: nova
  tenant: include_test_tenant
  security_group:
  - 1
  networks:
    eth0:
      allowed_address_pairs:
      - 10.2.0.0
      bootproto: static
      ip_address: 1.1.1.1/24
      gateway: 1.1.1.254
  templates:
  - user_data_template
  user_data:
    hostname: pyama-test001
    users:
    - name: 1
  keypair: example001
EOS
end
