require 'spec_helper'
require 'support/configure'
require 'base64'
describe Pec::Configure do
  describe 'value check' do
    before do
      @configure = Pec::Configure.new("spec/fixture/in/pec_configure_p1.yaml")
      Pec::Resource.set_tenant("1")
    end

    it 'host' do
      host = @configure.first
      expect(host.flavor).to eq("m1.small")
      expect(host.image).to eq("centos-7.1_chef-12.3_puppet-3.7")
      expect(host.name).to eq("pyama-test001.test.com")
      expect(host.availability_zone).to eq("nova")
    end

    it 'ether' do
      net = @configure.first.networks.first
      expect(net.bootproto).to eq("static")
      expect(net.ip_address).to eq("1.1.1.1/24")
      expect(net.name).to eq("eth0")
      expect(net.options).to eq({"gateway" => "1.1.1.254"})
    end

    it "security_group" do
      expect(@configure.first.security_group).to eq([1, 2])
    end

    it "user_data" do
      host = @configure.first
      expect_data = YAML.load_file("spec/fixture/in/pec_configure_p2.yaml").to_hash
      allow(YAML).to receive(:load_file).and_return(YAML.load_file("spec/fixture/stub/pec_configure_p1.yaml"))
      allow(FileTest).to receive(:exist?).and_return(true)
      expect(Pec::Configure::UserData.make(host)).to eq(
        { 'user_data' => Base64.encode64("#cloud-config\n" + expect_data.deep_merge(host.user_data).to_yaml) }
      )
    end
  end

  describe 'validate' do
    describe 'host' do
      describe 'require column' do
        shared_examples_for 'base no error' do
          it do
            expect { Pec::Configure.new(get_delete_column_hash(column))}.not_to raise_error
          end
        end
        shared_examples_for 'require test' do
          it do
            expect { Pec::Configure.new(get_delete_column_hash(column))}.to raise_error(Pec::Errors::Host)
          end
        end

        shared_examples_for 'null test' do
          it do
            expect { Pec::Configure.new(get_nil_column_hash(column))}.to raise_error(Pec::Errors::Host)
          end
        end

        describe 'image' do
          let(:column) { "image" }
          it_behaves_like 'require test'
          it_behaves_like 'null test'
        end
        describe 'flavor' do
          let(:column) { "flavor" }
          it_behaves_like 'require test'
          it_behaves_like 'null test'
        end
        describe 'tenant' do
          let(:column) { "tenant" }
          it_behaves_like 'require test'
          it_behaves_like 'null test'
        end
      end
    end

    describe 'network' do
      describe 'require' do
        describe 'bootproto' do
          it { expect { Pec::Configure.new(get_delete_network_column_hash("bootproto")) }.to raise_error(Pec::Errors::Ethernet) }
        end
        describe 'ip address by bootproto is static' do
          it { expect { Pec::Configure.new(get_delete_network_column_hash("ip_address")) }.to raise_error(Pec::Errors::Ethernet) }
        end
      end
      describe 'unknown bootproto' do
        describe 'not static and dhcp' do
          it { expect { Pec::Configure.new(set_network_bootproto("hoge")) }.to raise_error(Pec::Errors::Ethernet) }
        end
      end
    end
  end
end

