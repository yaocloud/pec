require 'spec_helper'
describe Pec::Network::Port do
  describe 'assign' do
    describe 'FreePort' do
      describe 'fixedip' do
        before do
          @port = Pec::Network::Port.assign("eth0", IP.new("1.1.1.1/24"), nil)
        end
        it do
          expect( @port.ip_address ).to eq("1.1.1.1")
          expect( @port.exists?).to eq true
          expect( @port.used?).to eq false
        end
      end
      describe 'dhcp' do
        before do
          @port = Pec::Network::Port.assign("eth0", IP.new("1.1.1.0/24"), nil)
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
        it do
          expect{ Pec::Network::Port.assign("eth0", IP.new("2.2.2.2/24"), nil) }.to raise_error(Pec::Errors::Port)
        end
      end
      describe 'dhcp' do
        it do
          expect{ Pec::Network::Port.assign("eth0", IP.new("2.2.2.0/24"), nil) }.to raise_error(Pec::Errors::Port)
        end
      end
    end
  end
end
