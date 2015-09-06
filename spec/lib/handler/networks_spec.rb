require 'spec_helper'
require 'ostruct'
describe Pec::Handler::Networks do
  before do
    Pec.load_config("spec/fixture/load_config_001.yaml")
    allow(Yao::Port).to receive(:create).and_return(OpenStruct.new({
      id: 1,
      name: "eth0",
      mac_address: '00:00:00:00:00:00',
      fixed_ips: [
        {
          'ip_address' => "10.10.10.10"
        }
      ]
    }))

    allow(Yao::SecurityGroup).to receive(:list).and_return([
      OpenStruct.new({
        id: 1,
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
  end

  context 'build' do
    subject {
      described_class.build(Pec.configure.first)
    }

    it do
      expect(subject).to eq(
        {
          networks: [
            {
              uuid: nil,
              port: 1
            }
          ],
          user_data: {
            "write_files" => [
                "content"     => "NAME=eth0\nDEVICE=eth0\nTYPE=Ethernet\nONBOOT=yes\nHWADDR=00:00:00:00:00:00\nNETMASK=255.255.255.0\nIPADDR=10.10.10.10\nBOOTPROTO=static\nGATEWAY=1.1.1.254",
                "owner"       => "root:root",
                "path"        => "/etc/sysconfig/network-scripts/ifcfg-eth0",
                "permissions" => "0644"
            ]
          }
        }
      )
    end
  end

  context 'port attribute' do
    before do
      allow(described_class).to receive(:security_group).and_return({security_groups: [1]})
    end

    context  'static' do
      before do
        allow(Yao::Subnet).to receive(:list).and_return([
          OpenStruct.new({
            id: 1,
            network_id: 1,
            cidr: "1.1.1.0/24",
          })
        ])
      end

      subject {
        described_class.gen_port_attribute(
          Pec.configure.first,
          Pec.configure.first.networks.first
        )
      }

      it do
        expect(subject).to eq({
          :name=>"eth0",
          :network_id=>1,
          :security_groups=> [1],
          :allowed_address_pairs=>[{
            :ip_address => "10.2.0.0"
          }],
          :fixed_ips => [{
            :subnet_id => 1,
            :ip_address => "1.1.1.1"
          }]
        })
      end
    end

    context  'any_address' do
      before do
        Pec.configure.first.networks['eth0']['ip_address'] = '1.1.1.0/24'
      end
      subject {
        described_class.gen_port_attribute(
          Pec.configure.first,
          Pec.configure.first.networks.first
        )
      }
      it do
        expect(subject).to eq(
          {
            name: "eth0",
            network_id: 1,
            security_groups: [1],
            allowed_address_pairs: [{
              ip_address: "10.2.0.0"
            }]
          }
        )
      end
    end
  end
end
