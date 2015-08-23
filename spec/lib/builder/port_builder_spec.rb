require 'spec_helper'
require 'ostruct'
describe Pec::Builder::Port do
  before do
    Pec.load_config("spec/fixture/load_config_001.yaml")
    allow_any_instance_of(described_class).to receive(:create_port).and_return(OpenStruct.new({
      id: 1,
      name: "eth0",
      mac_address: '00:00:00:00:00:00',
      fixed_ips: [
        {
          'ip_address' => "10.10.10.10/24"
        }
      ]
    }))
  end
 
  context 'build' do
    subject {
      described_class.new.build(Pec.configure.first)
    }  

    it do
      expect(subject).to eq(
        {
          nics: [
            { port_id: 1 }
          ]
        }
      )
    end
  end
  
  context 'user data' do
    before do
      @builder = described_class.new
      @builder.build(Pec.configure.first)
    end

    subject {
      @builder.user_data
    }  

    it do
      expect(subject).to eq(
        [
          {
            "content"     => "NAME=eth0\nDEVICE=eth0\nTYPE=Ethernet\nONBOOT=yes\nHWADDR=00:00:00:00:00:00\nNETMASK=255.255.255.0\nIPADDR=10.10.10.10\nBOOTPROTO=static\nGATEWAY=1.1.1.254",
            "owner"       => "root:root",
            "path"        => "/etc/sysconfig/network-scripts/ifcfg-eth0",
            "permissions" => "0644"
          }
        ]
      )
    end
  end

  context 'port attribute' do
    before do
      allow_any_instance_of(described_class).to receive(:security_group).and_return({security_groups: [1]}) 
    end

    context  'static' do
      subject {
        described_class.new.gen_port_attribute(
          Pec.configure.first,
          Pec.configure.first.networks.first,
          OpenStruct.new({
            id: 1,
            network_id: 1,
            cidr: "1.1.1.0/24",
          }),
          IP.new(Pec.configure.first.networks.first[1]['ip_address'])
        )
      }  
      it do
        expect(subject).to eq(
          {
            name: "eth0",
            network_id: 1,
            fixed_ips: [
              {
                subnet_id: 1,
                 ip_address:"1.1.1.1"
              }
            ],
            security_groups: [1],
            allowed_address_pairs: [
              {
                ip_address: "10.2.0.0"
              }
            ]
          }
        )
      end
    end
    context  'dhcp' do
      subject {
        described_class.new.gen_port_attribute(
          Pec.configure.first,
          Pec.configure.first.networks.first,
          OpenStruct.new({
            id: 1,
            network_id: 1,
            cidr: "1.1.1.1/24",
          }),
          IP.new(Pec.configure.first.networks.first[1]['ip_address'])
        )
      }  
      it do
        expect(subject).to eq(
          {
            name: "eth0",
            network_id: 1,
            security_groups: [1],
            allowed_address_pairs: [
              {
                ip_address: "10.2.0.0"
              }
            ]
          }
        )
      end
    end
  end
end
