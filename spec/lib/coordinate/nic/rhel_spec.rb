require 'spec_helper'
require 'support/nic_helper'
require 'ostruct'

describe Pec::Coordinate::UserData::Nic::Rhel do
  subject { described_class.gen_user_data(networks, ports) }
  it {
    expect(subject).to eq(
      [
        {
          "content" => "NAME=eth0\nDEVICE=eth0\nTYPE=Ethernet\nONBOOT=yes\nHWADDR=00:00:00:00:00:00\nNETMASK=255.255.255.0\nIPADDR=10.10.10.10\nBOOTPROTO=static\nDNS-NAMESERVERS=8.8.8.8\nGATEWAY=1.1.1.1",
          "owner" => "root:root",
          "path" => "/etc/sysconfig/network-scripts/ifcfg-eth0",
          "permissions" => "0644"
        },
        {
          "content" => "NAME=eth1\nDEVICE=eth1\nTYPE=Ethernet\nONBOOT=yes\nHWADDR=00:00:00:00:00:00\nNETMASK=255.255.255.0\nIPADDR=20.20.20.20\nBOOTPROTO=static\nDNS-NAMESERVERS=8.8.8.8\nGATEWAY=2.2.2.2",
          "owner" => "root:root",
          "path" => "/etc/sysconfig/network-scripts/ifcfg-eth1",
          "permissions" => "0644"
        }
      ]
    )
  }
end

