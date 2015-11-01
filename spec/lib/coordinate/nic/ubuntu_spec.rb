require 'spec_helper'
require 'ostruct'

describe Pec::Coordinate::UserData::Nic::Ubuntu do

  subject { Pec::Coordinate::UserData::Nic::Ubuntu.gen_user_data(networks, ports) }
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

def ports
  [
    OpenStruct.new({
      id: 1,
      name: "eth0",
      mac_address: '00:00:00:00:00:00',
      fixed_ips: [
        {
          'ip_address' => "10.10.10.10"
        }
      ]
    }),
    OpenStruct.new({
      id: 1,
      name: "eth1",
      mac_address: '00:00:00:00:00:00',
      fixed_ips: [
        {
          'ip_address' => "20.20.20.20"
        }
      ]
    })
  ]
end

def networks
  [
    [
      "eth0",
      {
        "bootproto" => "static",
        "ip_address" => "10.10.10.10/24",
        "dns-nameservers" => "8.8.8.8",
        "gateway" => "1.1.1.1"
      }
    ],
    [
      "eth1",
      {
        "bootproto" => "static",
        "ip_address" => "20.20.20.20/24",
        "dns-nameservers" => "8.8.8.8",
        "gateway" => "2.2.2.2"
      }
    ]
  ]
end
