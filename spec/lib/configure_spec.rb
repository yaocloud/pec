require 'spec_helper'
require 'base64'
describe Pec::Configure do
  describe 'standard' do
    before do
      @configure = Pec::Configure.new("spec/fixture/in/pec_configure_starndard_p1.yaml")
    end

    it 'host' do
      host = @configure.first
      expect(host.flavor).to eq("m1.small")
      expect(host.image).to eq("centos-7.1_chef-12.3_puppet-3.7")
      expect(host.name).to eq("pyama-test001")
    end

    it 'ether' do
      net = @configure.first.networks.first
      expect(net.bootproto).to eq("static")
      expect(net.ip_address).to eq("10.10.10.10/24")
      expect(net.name).to eq("eth0")
      expect(net.options).to eq({"gateway" => "10.10.10.254"})
    end

    it "security_group" do
      expect(@configure.first.security_group).to eq(["default", "office"])
    end

    it "user_data" do
      host = @configure.first
      allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/stub/pec_configure_standard_p1.yaml"))
      allow(FileTest).to receive(:exist?).and_return(true)
      expect(Pec::Configure::UserData.make(host, nil)).to eq(
        Base64.encode64("#cloud-config\n" + host.user_data.merge(YAML.load_file("spec/fixture/stub/pec_configure_standard_p1.yaml").to_hash).to_yaml)
      )
    end
  end
  describe 'validate' do
    describe 'host' do
      describe 'require' do
        it 'images' do
          expect(lambda { Pec::Configure.new("spec/fixture/in/pec_configure_starndard_p2.yaml") }).to raise_error(Pec::Errors::Host)
        end
        it 'flavor' do
          expect(lambda { Pec::Configure.new("spec/fixture/in/pec_configure_starndard_p3.yaml") }).to raise_error(Pec::Errors::Host)
        end
      end
      describe 'is nil?' do
        it 'images' do
          expect(lambda { Pec::Configure.new("spec/fixture/in/pec_configure_starndard_p4.yaml") }).to raise_error(Pec::Errors::Host)
        end
        it 'flavor' do
          expect(lambda { Pec::Configure.new("spec/fixture/in/pec_configure_starndard_p5.yaml") }).to raise_error(Pec::Errors::Host)
        end
      end
    end
    describe 'network' do
      describe 'require' do
        it 'bootproto' do
          expect(lambda { Pec::Configure.new("spec/fixture/in/pec_configure_starndard_p6.yaml") }).to raise_error(Pec::Errors::Ethernet)
        end
        it 'ip address by bootproto is static' do
          expect(lambda { Pec::Configure.new("spec/fixture/in/pec_configure_starndard_p7.yaml") }).to raise_error(Pec::Errors::Ethernet)
        end
      end
      describe 'unknown bootproto' do
        it 'not static and dhcp' do
          expect(lambda { Pec::Configure.new("spec/fixture/in/pec_configure_starndard_p8.yaml") }).to raise_error(Pec::Errors::Ethernet)
        end
      end
    end
  end
end
