require 'spec_helper'
require 'support/nic_helper'
require 'ostruct'

describe Pec::Coordinate::UserData::Nic::Ubuntu do

  subject { described_class.gen_user_data(networks, ports) }
  it {
    expect(subject).to eq(
      {
        "content"=> "auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet static\naddress 10.10.10.10\nnetmask 255.255.255.0\nhwaddress ether 00:00:00:00:00:00\nbootproto static\ndns-nameservers 8.8.8.8\ngateway 1.1.1.1\nauto eth1\niface eth1 inet static\naddress 20.20.20.20\nnetmask 255.255.255.0\nhwaddress ether 00:00:00:00:00:00\nbootproto static\ndns-nameservers 8.8.8.8\ngateway 2.2.2.2",
        "owner" => "root:root",
        "path" => "/etc/network/interfaces",
        "permissions" => "0644"
      }
    )
  }
end
