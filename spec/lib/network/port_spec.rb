require 'spec_helper'
require 'support/configure'
describe Pec::Network::Port do
  describe 'assign' do
    describe 'FreePort' do
      describe 'fixedip' do
        before do
          ether = Pec::Configure::Ethernet.new("eth0", get_ether_static_config)
          @port = Pec::Network::Port.assign(ether, nil)
        end
        it do
          expect( @port.ip_address ).to eq("1.1.1.1")
          expect( @port.exists?).to eq true
          expect( @port.used?).to eq false
        end
      end
      describe 'dhcp' do
        before do
          ether = Pec::Configure::Ethernet.new("eth0", get_ether_dhcp_config)
          @port = Pec::Network::Port.assign(ether, nil)
        end
        it do
          expect( @port.ip_address ).to eq("1.1.1.1")
          expect( @port.exists?).to eq true
          expect( @port.used?).to eq false
        end
      end
    end

    describe 'Used' do
      describe 'fixedip' do
        before do
          @ether = Pec::Configure::Ethernet.new("eth0", get_ether_use_static_config)
        end

        it do
          expect{ Pec::Network::Port.assign(@ether, nil) }.to raise_error(Pec::Errors::Port)
        end
      end
    end
  end
end
