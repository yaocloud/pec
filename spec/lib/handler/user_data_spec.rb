require 'spec_helper'
require 'support/nic_helper'
describe Pec::Handler::UserData do
  before do
    Pec.load_config("spec/fixture/basic_config.yaml")
    allow(FileTest).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/user_data_template.yaml"))
  end

  subject {
    described_class.build(Pec.configure.first)
  }

  it 'value_check' do
    expect(subject).to eq(
      {
        :user_data =>
        {
          "hostname" => "pyama-test001",
          "users"=> [
            {
              "name" => 1
            }
          ],
          "fqdn" => "pyama-test001.test.com"
        }
      }
    )
  end

  describe Pec::Handler::UserData::Nic::Ubuntu do

    subject { described_class.gen_user_data(networks, ports) }
    it {
      expect(subject).to eq(
        [
          {
            "content" => "auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet static\naddress 10.10.10.10\nnetmask 255.255.255.0\nhwaddress ether 00:00:00:00:00:00\ndns-nameservers 8.8.8.8\ngateway 1.1.1.1\nauto eth1\niface eth1 inet static\naddress 20.20.20.20\nnetmask 255.255.255.0\nhwaddress ether 00:00:00:00:00:00\ndns-nameservers 8.8.8.8\ngateway 2.2.2.2",
            "owner" => "root:root",
            "path" => "/etc/network/interfaces",
            "permissions" => "0644"
          }
        ]
      )
    }
  end

  describe Pec::Handler::UserData::Nic::Rhel do
    subject { described_class.gen_user_data(networks, ports) }
    it {
      expect(subject).to eq(
        [
          {
            "content" => "NAME=eth0\nDEVICE=eth0\nTYPE=Ethernet\nONBOOT=yes\nHWADDR=00:00:00:00:00:00\nNETMASK=255.255.255.0\nIPADDR=10.10.10.10\nBOOTPROTO=static\nDNS-NAMESERVERS=8.8.8.8\nGATEWAY=1.1.1.1\n",
            "owner" => "root:root",
            "path" => "/etc/sysconfig/network-scripts/ifcfg-eth0",
            "permissions" => "0644"
          },
          {
            "content" => "NAME=eth1\nDEVICE=eth1\nTYPE=Ethernet\nONBOOT=yes\nHWADDR=00:00:00:00:00:00\nNETMASK=255.255.255.0\nIPADDR=20.20.20.20\nBOOTPROTO=static\nDNS-NAMESERVERS=8.8.8.8\nGATEWAY=2.2.2.2\n",
            "owner" => "root:root",
            "path" => "/etc/sysconfig/network-scripts/ifcfg-eth1",
            "permissions" => "0644"
          }
        ]
      )
    }
  end

end
