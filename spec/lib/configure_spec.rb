require 'spec_helper'
require 'base64'
describe Pec::Configure do
  describe 'standard p1' do
    before do
      @configure = Pec::Configure.new
      @configure.load("spec/fixture/in/pec_configure_starndard_p1.yaml")
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
end
